package com.crontools.app.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class CronServiceTest {

    private CronService cronService;

    @BeforeEach
    void setUp() {
        cronService = new CronService();
        ReflectionTestUtils.setField(cronService, "defaultTimezone", "Asia/Shanghai");
    }

    @Test
    void testParseCronToHuman_EveryDay() {
        String result = cronService.parseCronToHuman("0 0 4 * * ?");
        assertEquals("每天 04:00 执行", result);
    }

    @Test
    void testParseCronToHuman_EveryDayWithMinutes() {
        String result = cronService.parseCronToHuman("0 30 9 * * ?");
        assertEquals("每天 09:30 执行", result);
    }

    @Test
    void testParseCronToHuman_Weekdays() {
        String result = cronService.parseCronToHuman("0 30 9 ? * MON-FRI");
        assertEquals("工作日 09:30 执行", result);
    }

    @Test
    void testParseCronToHuman_EveryHour() {
        String result = cronService.parseCronToHuman("0 0 * * * ?");
        assertEquals("每小时整点执行", result);
    }

    @Test
    void testParseCronToHuman_Every6Hours() {
        String result = cronService.parseCronToHuman("0 0 0/6 * * ?");
        assertEquals("每6小时执行", result);
    }

    @Test
    void testParseCronToHuman_CustomExpression() {
        String result = cronService.parseCronToHuman("0 15 10 ? * MON");
        assertEquals("自定义调度: 0 15 10 ? * MON", result);
    }

    @Test
    void testParseCronToHuman_InvalidExpression() {
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            cronService.parseCronToHuman("invalid cron");
        });
        assertTrue(exception.getMessage().contains("无效的 Cron 表达式"));
    }

    @Test
    void testParseCronToHuman_InvalidQuartzExpression() {
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            cronService.parseCronToHuman("0 30 9 * * MON-FRI");
        });
        assertTrue(exception.getMessage().contains("无效的 Cron 表达式"));
    }

    @Test
    void testGetNextExecutionTimes_ValidExpression() {
        List<String> result = cronService.getNextExecutionTimes("0 0 4 * * ?", "Asia/Shanghai", 3);
        
        assertNotNull(result);
        assertEquals(3, result.size());
        
        // 检查格式是否正确
        for (String time : result) {
            assertTrue(time.contains("04:00:00"));
            assertTrue(time.contains("Asia/Shanghai"));
        }
    }

    @Test
    void testGetNextExecutionTimes_WeekdaysExpression() {
        List<String> result = cronService.getNextExecutionTimes("0 30 9 ? * MON-FRI", "Asia/Shanghai", 2);
        
        assertNotNull(result);
        assertEquals(2, result.size());
        
        for (String time : result) {
            assertTrue(time.contains("09:30:00"));
            assertTrue(time.contains("Asia/Shanghai"));
        }
    }

    @Test
    void testGetNextExecutionTimes_InvalidExpression() {
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            cronService.getNextExecutionTimes("invalid", "Asia/Shanghai", 5);
        });
        assertTrue(exception.getMessage().contains("无法计算执行时间"));
    }

    @Test
    void testGetNextExecutionTimes_DefaultTimezone() {
        List<String> result = cronService.getNextExecutionTimes("0 0 12 * * ?", null, 1);
        
        assertNotNull(result);
        assertEquals(1, result.size());
        assertTrue(result.get(0).contains("Asia/Shanghai"));
    }

    @Test
    void testGetNextExecutionTimes_CustomTimezone() {
        List<String> result = cronService.getNextExecutionTimes("0 0 12 * * ?", "UTC", 1);
        
        assertNotNull(result);
        assertEquals(1, result.size());
        assertTrue(result.get(0).contains("UTC"));
    }

    @Test
    void testGetNextExecutionTimes_LimitCount() {
        List<String> result = cronService.getNextExecutionTimes("0 0 12 * * ?", "Asia/Shanghai", 10);
        
        assertNotNull(result);
        assertEquals(10, result.size());
    }
}