package com.nexabyte.taskflow.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.Issue;

@Repository
public interface IssueRepository extends JpaRepository<Issue, Long> {

    Page<Issue> findByCreatedBy(Long userId, Pageable pageable);

    Page<Issue> findByWorkPackageAccountableId(Long userId, Pageable pageable);
}
