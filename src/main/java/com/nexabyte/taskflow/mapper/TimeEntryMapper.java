package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.timeentry.TimeEntryDto;
import com.nexabyte.taskflow.entities.TimeEntry;

public class TimeEntryMapper {

    public static TimeEntryDto toDto(TimeEntry entry) {
        return TimeEntryDto.builder()
                .id(entry.getId())
                .workPackageId(entry.getWorkPackage().getId())
                .userId(entry.getUser().getId())
                .username(entry.getUser().getUsername())
                .hours(entry.getHours())
                .comment(entry.getComment())
                .spentOn(entry.getSpentOn())
                .createdAt(entry.getCreatedAt())
                .updatedAt(entry.getUpdatedAt())
                .createdBy(entry.getCreatedBy())
                .updatedBy(entry.getUpdatedBy())
                .build();
    }
}
