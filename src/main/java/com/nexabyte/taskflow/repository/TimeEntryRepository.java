package com.nexabyte.taskflow.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.TimeEntry;

@Repository
public interface TimeEntryRepository extends JpaRepository<TimeEntry, Long> {

    Page<TimeEntry> findByWorkPackageId(Long workPackageId, Pageable pageable);

    Page<TimeEntry> findByUserId(Long userId, Pageable pageable);

}
