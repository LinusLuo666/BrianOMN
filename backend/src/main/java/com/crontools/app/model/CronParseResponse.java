package com.crontools.app.model;

public class CronParseResponse {
    private String expr;
    private String type;
    private String timezone;
    private String humanReadable;
    private boolean valid;
    private String message;

    public CronParseResponse() {}

    public CronParseResponse(String expr, String type, String timezone, String humanReadable, boolean valid, String message) {
        this.expr = expr;
        this.type = type;
        this.timezone = timezone;
        this.humanReadable = humanReadable;
        this.valid = valid;
        this.message = message;
    }

    // Getters and Setters
    public String getExpr() { return expr; }
    public void setExpr(String expr) { this.expr = expr; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTimezone() { return timezone; }
    public void setTimezone(String timezone) { this.timezone = timezone; }

    public String getHumanReadable() { return humanReadable; }
    public void setHumanReadable(String humanReadable) { this.humanReadable = humanReadable; }

    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}