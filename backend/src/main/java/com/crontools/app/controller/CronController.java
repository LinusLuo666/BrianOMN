package com.crontools.app.controller;

import com.crontools.app.model.CronParseResponse;
import com.crontools.app.model.NextTimesResponse;
import com.crontools.app.service.CronService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class CronController {

    @Autowired
    private CronService cronService;

    @Value("${app.default.timezone:Asia/Shanghai}")
    private String defaultTimezone;

    @GetMapping("/parse")
    public ResponseEntity<CronParseResponse> parseCron(
            @RequestParam String expr,
            @RequestParam(defaultValue = "QUARTZ") String type,
            @RequestParam(required = false) String tz) {
        
        try {
            String timezone = tz != null ? tz : defaultTimezone;
            String humanReadable = cronService.parseCronToHuman(expr);
            
            CronParseResponse response = new CronParseResponse(
                expr, type, timezone, humanReadable, true, ""
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            CronParseResponse response = new CronParseResponse(
                expr, type, tz != null ? tz : defaultTimezone, "", false, e.getMessage()
            );
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/next-times")
    public ResponseEntity<NextTimesResponse> getNextTimes(
            @RequestParam String expr,
            @RequestParam(defaultValue = "QUARTZ") String type,
            @RequestParam(required = false) String tz,
            @RequestParam(defaultValue = "5") int count) {
        
        try {
            if (count > 20) count = 20;
            if (count < 1) count = 1;
            
            String timezone = tz != null ? tz : defaultTimezone;
            List<String> nextTimes = cronService.getNextExecutionTimes(expr, timezone, count);
            
            NextTimesResponse response = new NextTimesResponse(nextTimes, true, "");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            NextTimesResponse response = new NextTimesResponse(null, false, e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}