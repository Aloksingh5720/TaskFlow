package com.nexabyte.taskflow.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.nexabyte.taskflow.dto.timeentry.TimeEntryDto;

public interface TimeEntryService {

    TimeEntryDto logTime(Long workPackageId, TimeEntryDto dto, Long userId);

    TimeEntryDto getTimeEntry(Long id);

    TimeEntryDto updateTimeEntry(Long entryId, TimeEntryDto dto, Long userId);

    void deleteTimeEntry(Long entryId, Long userId);

    Page<TimeEntryDto> getTimeEntriesForWorkPackage(Long workPackageId, Pageable pageable);

    Page<TimeEntryDto> getTimeEntriesForUser(Long userId, Pageable pageable);
}
