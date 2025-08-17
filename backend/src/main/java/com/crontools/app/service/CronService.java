package com.crontools.app.service;

import com.cronutils.model.Cron;
import com.cronutils.model.CronType;
import com.cronutils.model.definition.CronDefinition;
import com.cronutils.model.definition.CronDefinitionBuilder;
import com.cronutils.model.time.ExecutionTime;
import com.cronutils.parser.CronParser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class CronService {

    @Value("${app.default.timezone:Asia/Shanghai}")
    private String defaultTimezone;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public String parseCronToHuman(String cronExpression) {
        try {
            CronDefinition cronDefinition = CronDefinitionBuilder.instanceDefinitionFor(CronType.QUARTZ);
            CronParser parser = new CronParser(cronDefinition);
            Cron cron = parser.parse(cronExpression);
            cron.validate();
            
            return generateHumanReadable(cronExpression);
        } catch (Exception e) {
            throw new IllegalArgumentException("无效的 Cron 表达式: " + e.getMessage());
        }
    }

    public List<String> getNextExecutionTimes(String cronExpression, String timezone, int count) {
        try {
            CronDefinition cronDefinition = CronDefinitionBuilder.instanceDefinitionFor(CronType.QUARTZ);
            CronParser parser = new CronParser(cronDefinition);
            Cron cron = parser.parse(cronExpression);
            cron.validate();

            ExecutionTime executionTime = ExecutionTime.forCron(cron);
            ZoneId zoneId = ZoneId.of(timezone != null ? timezone : defaultTimezone);
            ZonedDateTime now = ZonedDateTime.now(zoneId);

            List<String> nextTimes = new ArrayList<>();
            ZonedDateTime nextExecution = now;

            for (int i = 0; i < count; i++) {
                Optional<ZonedDateTime> next = executionTime.nextExecution(nextExecution);
                if (next.isPresent()) {
                    nextExecution = next.get();
                    nextTimes.add(nextExecution.format(FORMATTER) + " (" + zoneId + ")");
                } else {
                    break;
                }
            }

            return nextTimes;
        } catch (Exception e) {
            throw new IllegalArgumentException("无法计算执行时间: " + e.getMessage());
        }
    }

    private String generateHumanReadable(String cronExpression) {
        String[] parts = cronExpression.trim().split("\\s+");
        
        if (parts.length != 6) {
            return "无法解析的 Cron 表达式";
        }

        String seconds = parts[0];
        String minutes = parts[1];
        String hours = parts[2];
        String dayOfMonth = parts[3];
        String month = parts[4];
        String dayOfWeek = parts[5];

        StringBuilder description = new StringBuilder();

        // 简单的中文描述生成逻辑
        if ("0".equals(seconds) && "*".equals(minutes) && "*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每分钟执行");
        } else if ("0".equals(seconds) && "0".equals(minutes) && "*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每小时整点执行");
        } else if ("0".equals(seconds) && "0".equals(minutes) && !"*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每天 ").append(String.format("%02d", Integer.parseInt(hours))).append(":00 执行");
        } else if ("0".equals(seconds) && !"*".equals(minutes) && !"*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每天 ").append(String.format("%02d:%02d", Integer.parseInt(hours), Integer.parseInt(minutes))).append(" 执行");
        } else {
            description.append("自定义调度: ").append(cronExpression);
        }

        return description.toString();
    }
}