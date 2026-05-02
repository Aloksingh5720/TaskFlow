package com.nexabyte.taskflow.service.impl;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.dto.timeentry.TimeEntryDto;
import com.nexabyte.taskflow.entities.TimeEntry;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.exception.AccessDeniedException;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.TimeEntryMapper;
import com.nexabyte.taskflow.repository.TimeEntryRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.TimeEntryService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class TimeEntryServiceImpl implements TimeEntryService {

    private final TimeEntryRepository timeEntryRepository;
    private final WorkPackageRepository workPackageRepository;
    private final UserRepository userRepository;

    @Override
    public TimeEntryDto logTime(Long workPackageId, TimeEntryDto dto, Long userId) {
        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(() -> new ResourceNotFoundException("Work package not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        TimeEntry entry = new TimeEntry();
        entry.setWorkPackage(workPackage);
        entry.setUser(user);
        entry.setHours(dto.getHours());
        entry.setComment(dto.getComment());
        entry.setSpentOn(dto.getSpentOn());

        entry = timeEntryRepository.save(entry);
        return TimeEntryMapper.toDto(entry);
    }

    @Override
    public TimeEntryDto getTimeEntry(Long id) {
        TimeEntry entry = timeEntryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Time entry not found with id: " + id));
        return TimeEntryMapper.toDto(entry);
    }

    @Override
    public TimeEntryDto updateTimeEntry(Long entryId, TimeEntryDto dto, Long userId) {
        TimeEntry entry = timeEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("Time entry not found"));

        if (!entry.getUser().getId().equals(userId) && !isAdmin(userId)) {
            throw new AccessDeniedException("You can only edit your own time entries");
        }
        entry.setHours(dto.getHours());
        entry.setComment(dto.getComment());
        entry.setSpentOn(dto.getSpentOn());

        entry = timeEntryRepository.save(entry);
        return TimeEntryMapper.toDto(entry);
    }

    @Override
    public void deleteTimeEntry(Long entryId, Long userId) {
        TimeEntry entry = timeEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("Time entry not found"));

        if (!entry.getUser().getId().equals(userId) && !isAdmin(userId)) {
            throw new AccessDeniedException("You can only delete your own time entries");
        }
        timeEntryRepository.delete(entry);
    }

    @Override
    public Page<TimeEntryDto> getTimeEntriesForWorkPackage(Long workPackageId, Pageable pageable) {
        return timeEntryRepository.findByWorkPackageId(workPackageId, pageable)
                .map(TimeEntryMapper::toDto);
    }

    @Override
    public Page<TimeEntryDto> getTimeEntriesForUser(Long userId, Pageable pageable) {
        return timeEntryRepository.findByUserId(userId, pageable)
                .map(TimeEntryMapper::toDto);
    }

    private boolean isAdmin(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return user.getGlobalRole().getName().equals(GlobalRole.SUPER_ADMIN);
    }
}
