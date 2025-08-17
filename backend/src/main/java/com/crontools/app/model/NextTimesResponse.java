package com.crontools.app.model;

import java.util.List;

public class NextTimesResponse {
    private List<String> nextTimes;
    private boolean valid;
    private String message;

    public NextTimesResponse() {}

    public NextTimesResponse(List<String> nextTimes, boolean valid, String message) {
        this.nextTimes = nextTimes;
        this.valid = valid;
        this.message = message;
    }

    // Getters and Setters
    public List<String> getNextTimes() { return nextTimes; }
    public void setNextTimes(List<String> nextTimes) { this.nextTimes = nextTimes; }

    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}