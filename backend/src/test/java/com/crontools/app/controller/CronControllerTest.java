package com.crontools.app.controller;

import com.crontools.app.service.CronService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CronController.class)
class CronControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CronService cronService;

    @Test
    void testParseCron_ValidExpression() throws Exception {
        when(cronService.parseCronToHuman("0 0 4 * * ?"))
                .thenReturn("每天 04:00 执行");

        mockMvc.perform(get("/api/parse")
                        .param("expr", "0 0 4 * * ?"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid").value(true))
                .andExpect(jsonPath("$.expr").value("0 0 4 * * ?"))
                .andExpect(jsonPath("$.type").value("QUARTZ"))
                .andExpect(jsonPath("$.humanReadable").value("每天 04:00 执行"))
                .andExpect(jsonPath("$.message").value(""));
    }

    @Test
    void testParseCron_InvalidExpression() throws Exception {
        when(cronService.parseCronToHuman("invalid"))
                .thenThrow(new IllegalArgumentException("无效的 Cron 表达式"));

        mockMvc.perform(get("/api/parse")
                        .param("expr", "invalid"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.valid").value(false))
                .andExpect(jsonPath("$.expr").value("invalid"))
                .andExpect(jsonPath("$.humanReadable").value(""))
                .andExpect(jsonPath("$.message").value("无效的 Cron 表达式"));
    }

    @Test
    void testParseCron_WithCustomTimezone() throws Exception {
        when(cronService.parseCronToHuman("0 0 4 * * ?"))
                .thenReturn("每天 04:00 执行");

        mockMvc.perform(get("/api/parse")
                        .param("expr", "0 0 4 * * ?")
                        .param("tz", "UTC"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid").value(true))
                .andExpect(jsonPath("$.timezone").value("UTC"));
    }

    @Test
    void testGetNextTimes_ValidExpression() throws Exception {
        List<String> nextTimes = Arrays.asList(
                "2024-01-01 04:00:00 (Asia/Shanghai)",
                "2024-01-02 04:00:00 (Asia/Shanghai)",
                "2024-01-03 04:00:00 (Asia/Shanghai)"
        );

        when(cronService.getNextExecutionTimes(eq("0 0 4 * * ?"), anyString(), eq(3)))
                .thenReturn(nextTimes);

        mockMvc.perform(get("/api/next-times")
                        .param("expr", "0 0 4 * * ?")
                        .param("count", "3"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid").value(true))
                .andExpect(jsonPath("$.nextTimes").isArray())
                .andExpect(jsonPath("$.nextTimes.length()").value(3))
                .andExpect(jsonPath("$.nextTimes[0]").value("2024-01-01 04:00:00 (Asia/Shanghai)"))
                .andExpect(jsonPath("$.message").value(""));
    }

    @Test
    void testGetNextTimes_InvalidExpression() throws Exception {
        when(cronService.getNextExecutionTimes(eq("invalid"), anyString(), anyInt()))
                .thenThrow(new IllegalArgumentException("无法计算执行时间"));

        mockMvc.perform(get("/api/next-times")
                        .param("expr", "invalid"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.valid").value(false))
                .andExpect(jsonPath("$.nextTimes").isEmpty())
                .andExpect(jsonPath("$.message").value("无法计算执行时间"));
    }

    @Test
    void testGetNextTimes_CountLimits() throws Exception {
        List<String> nextTimes = Arrays.asList("2024-01-01 04:00:00 (Asia/Shanghai)");
        when(cronService.getNextExecutionTimes(anyString(), anyString(), eq(20)))
                .thenReturn(nextTimes);

        // 测试超过最大限制
        mockMvc.perform(get("/api/next-times")
                        .param("expr", "0 0 4 * * ?")
                        .param("count", "25"))
                .andExpect(status().isOk());

        // 测试低于最小限制
        mockMvc.perform(get("/api/next-times")
                        .param("expr", "0 0 4 * * ?")
                        .param("count", "0"))
                .andExpect(status().isOk());
    }

    @Test
    void testGetNextTimes_DefaultCount() throws Exception {
        List<String> nextTimes = Arrays.asList(
                "2024-01-01 04:00:00 (Asia/Shanghai)",
                "2024-01-02 04:00:00 (Asia/Shanghai)",
                "2024-01-03 04:00:00 (Asia/Shanghai)",
                "2024-01-04 04:00:00 (Asia/Shanghai)",
                "2024-01-05 04:00:00 (Asia/Shanghai)"
        );

        when(cronService.getNextExecutionTimes(eq("0 0 4 * * ?"), anyString(), eq(5)))
                .thenReturn(nextTimes);

        mockMvc.perform(get("/api/next-times")
                        .param("expr", "0 0 4 * * ?"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nextTimes.length()").value(5));
    }

    @Test
    void testHealth() throws Exception {
        mockMvc.perform(get("/api/health"))
                .andExpect(status().isOk())
                .andExpect(content().string("OK"));
    }
}