package com.nexabyte.taskflow.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.Activity;

@Repository
public interface ActivityRepository extends JpaRepository<Activity, Long> {

    List<Activity> findByUsers_Id(Long userId);

    Page<Activity> findByUsers_Id(Long userId, Pageable pageable);

    List<Activity> findByProjectId(Long projectId);

    Page<Activity> findByProjectId(Long projectId, Pageable pageable);

    List<Activity> findByProjectIdOrderByCreatedAtDesc(Long projectId);

    Page<Activity> findByProjectIdOrderByCreatedAtDesc(Long projectId, Pageable pageable);
}
