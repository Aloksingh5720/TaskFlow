package com.nexabyte.taskflow.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.Meeting;

@Repository
public interface MeetingRepository extends JpaRepository<Meeting, Long> {

    List<Meeting> findByProjectId(Long projectId);

    List<Meeting> findByProjectIdOrderByDateAscStartTimeAsc(Long projectId);

    Page<Meeting> findByProjectId(Long projectId, Pageable pageable);

    @Query("SELECT COUNT(m) > 0 FROM Meeting m JOIN m.participants p WHERE p.id = :userId")
    boolean existsByParticipantId(@Param("userId") Long userId);

    // Get meetings where user is a participant, ordered by date and time
    @Query("SELECT m FROM Meeting m JOIN m.participants p WHERE p.id = :userId ORDER BY m.date DESC, m.startTime DESC")
    List<Meeting> findAllByParticipantIdOrderByDateDesc(@Param("userId") Long userId);
}
