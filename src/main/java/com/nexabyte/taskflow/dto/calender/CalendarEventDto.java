package com.nexabyte.taskflow.dto.calender;

import java.time.LocalDate;
import java.time.LocalTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CalendarEventDto {

    private Long id;

    private String title;

    private String description;

    private LocalDate startDate;

    private LocalDate endDate;

    private LocalTime startTime;

    private LocalTime endTime;

    private String startDateTime;

    private String endDateTime;

    private String eventType;

    private Long projectId;

    private String projectName;

    private String url;

    private String status;

    private String priority;

    private String assigneeName;

    private String allDay;
}
