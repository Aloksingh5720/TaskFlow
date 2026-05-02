package com.nexabyte.taskflow.service;

import java.util.List;

import com.nexabyte.taskflow.dto.calender.CalendarEventDto;

public interface CalendarService {

    List<CalendarEventDto> getCalendarEventsForUser(Long userId);

    List<CalendarEventDto> getCalendarEventsForProject(Long projectId, Long userId);

    boolean canViewCalendar(Long userId);
}
