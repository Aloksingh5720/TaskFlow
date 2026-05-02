package com.nexabyte.taskflow.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;
import com.nexabyte.taskflow.entities.WorkPackage;

@Repository
public interface WorkPackageRepository extends JpaRepository<WorkPackage, Long> {

        boolean existsByUiId(String uiId);

        List<WorkPackage> findByUiIdIsNull();

        Page<WorkPackage> findByProjectId(Long projectId, Pageable pageable);

        Page<WorkPackage> findByProjectIdIn(List<Long> projectIds, Pageable pageable);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id = :projectId " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId)")
        Page<WorkPackage> findVisibleByProjectId(@Param("projectId") Long projectId,
                        @Param("userId") Long userId,
                        Pageable pageable);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id IN :projectIds " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId)")
        Page<WorkPackage> findVisibleByProjectIdIn(@Param("projectIds") List<Long> projectIds,
                        @Param("userId") Long userId,
                        Pageable pageable);

        // New method with filters for a single project
        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id = :projectId " +
                        "AND (:search IS NULL OR LOWER(wp.uiId) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR LOWER(wp.subject) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR STR(wp.id) LIKE CONCAT('%', :search, '%')) " +
                        "AND (:type IS NULL OR wp.workPackageType = :type) " +
                        "AND (:status IS NULL OR wp.workPackageStatus = :status) " +
                        "AND (:priority IS NULL OR wp.workPackagePriority = :priority) " +
                        "AND (:assigneeId IS NULL OR wp.assignee.id = :assigneeId)")
        Page<WorkPackage> findWorkPackagesWithFilters(@Param("projectId") Long projectId,
                        @Param("search") String search,
                        @Param("type") WorkPackageType type,
                        @Param("status") WorkPackageStatus status,
                        @Param("priority") WorkPackagePriority priority,
                        @Param("assigneeId") Long assigneeId,
                        Pageable pageable);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id = :projectId " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId) " +
                        "AND (:search IS NULL OR LOWER(wp.uiId) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR LOWER(wp.subject) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR STR(wp.id) LIKE CONCAT('%', :search, '%')) " +
                        "AND (:type IS NULL OR wp.workPackageType = :type) " +
                        "AND (:status IS NULL OR wp.workPackageStatus = :status) " +
                        "AND (:priority IS NULL OR wp.workPackagePriority = :priority) " +
                        "AND (:assigneeId IS NULL OR wp.assignee.id = :assigneeId)")
        Page<WorkPackage> findVisibleWorkPackagesWithFilters(@Param("projectId") Long projectId,
                        @Param("userId") Long userId,
                        @Param("search") String search,
                        @Param("type") WorkPackageType type,
                        @Param("status") WorkPackageStatus status,
                        @Param("priority") WorkPackagePriority priority,
                        @Param("assigneeId") Long assigneeId,
                        Pageable pageable);

        // New method with filters for multiple projects (including child projects)
        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id IN :projectIds " +
                        "AND (:search IS NULL OR LOWER(wp.uiId) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR LOWER(wp.subject) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR STR(wp.id) LIKE CONCAT('%', :search, '%')) " +
                        "AND (:type IS NULL OR wp.workPackageType = :type) " +
                        "AND (:status IS NULL OR wp.workPackageStatus = :status) " +
                        "AND (:priority IS NULL OR wp.workPackagePriority = :priority) " +
                        "AND (:assigneeId IS NULL OR wp.assignee.id = :assigneeId)")
        Page<WorkPackage> findWorkPackagesWithFiltersInProjects(@Param("projectIds") List<Long> projectIds,
                        @Param("search") String search,
                        @Param("type") WorkPackageType type,
                        @Param("status") WorkPackageStatus status,
                        @Param("priority") WorkPackagePriority priority,
                        @Param("assigneeId") Long assigneeId,
                        Pageable pageable);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id IN :projectIds " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId) " +
                        "AND (:search IS NULL OR LOWER(wp.uiId) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR LOWER(wp.subject) LIKE LOWER(CONCAT('%', :search, '%')) " +
                        "OR STR(wp.id) LIKE CONCAT('%', :search, '%')) " +
                        "AND (:type IS NULL OR wp.workPackageType = :type) " +
                        "AND (:status IS NULL OR wp.workPackageStatus = :status) " +
                        "AND (:priority IS NULL OR wp.workPackagePriority = :priority) " +
                        "AND (:assigneeId IS NULL OR wp.assignee.id = :assigneeId)")
        Page<WorkPackage> findVisibleWorkPackagesWithFiltersInProjects(@Param("projectIds") List<Long> projectIds,
                        @Param("userId") Long userId,
                        @Param("search") String search,
                        @Param("type") WorkPackageType type,
                        @Param("status") WorkPackageStatus status,
                        @Param("priority") WorkPackagePriority priority,
                        @Param("assigneeId") Long assigneeId,
                        Pageable pageable);

        @Query("SELECT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id = :projectId " +
                        "AND wp.workPackageStatus = :status")
        List<WorkPackage> findByProjectIdAndWorkPackageStatus(@Param("projectId") Long projectId,
                        @Param("status") WorkPackageStatus status);

        @Query("SELECT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id IN :projectIds " +
                        "AND wp.workPackageStatus = :status")
        List<WorkPackage> findByProjectIdInAndWorkPackageStatus(@Param("projectIds") List<Long> projectIds,
                        @Param("status") WorkPackageStatus status);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id IN :projectIds " +
                        "AND wp.workPackageStatus = :status " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId)")
        List<WorkPackage> findVisibleByProjectIdInAndWorkPackageStatus(@Param("projectIds") List<Long> projectIds,
                        @Param("userId") Long userId,
                        @Param("status") WorkPackageStatus status);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id = :projectId " +
                        "AND wp.workPackageStatus = :status " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId)")
        List<WorkPackage> findVisibleByProjectIdAndUserIdAndWorkPackageStatus(@Param("projectId") Long projectId,
                        @Param("userId") Long userId,
                        @Param("status") WorkPackageStatus status);

        /**
         * Get all work packages where the specified user is the assignee person with
         * pagination
         */
        @Query(value = "SELECT wp FROM WorkPackage wp WHERE wp.assignee.id = :userId")
        Page<WorkPackage> findAssignedWorkPackages(@Param("userId") Long userId, Pageable pageable);

        /**
         * Get all work packages where the specified user is the accountable person with
         * pagination
         */
        @Query("SELECT wp FROM WorkPackage wp WHERE wp.accountable.id = :userId")
        Page<WorkPackage> findAccountableWorkPackages(@Param("userId") Long userId, Pageable pageable);

        /**
         * Get all overdue work packages where the specified user is the assignee person
         * with pagination
         */
        @Query("SELECT wp FROM WorkPackage wp " +
                        "WHERE wp.assignee.id = :userId " +
                        "AND wp.dueDate < :date " +
                        "AND wp.workPackageStatus != 'COMPLETED'")
        Page<WorkPackage> findOverdueByAssigneeId(@Param("userId") Long userId, @Param("date") LocalDate date,
                        Pageable pageable);

        /**
         * Get all overdue work packages where the specified user is the accountable
         * person with pagination
         */
        @Query("SELECT wp FROM WorkPackage wp " +
                        "WHERE wp.accountable.id = :userId " +
                        "AND wp.dueDate < :date " +
                        "AND wp.workPackageStatus != 'COMPLETED'")
        Page<WorkPackage> findOverdueByAccountableId(@Param("userId") Long userId, @Param("date") LocalDate date,
                        Pageable pageable);

        /**
         * Get all overdue work packages where the specified user is either the assignee
         * or the accountable person with pagination
         */
        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE (wp.assignee.id = :userId OR wp.accountable.id = :userId) " +
                        "AND wp.dueDate < :date " +
                        "AND wp.workPackageStatus != 'COMPLETED'")
        Page<WorkPackage> findAllOverdueByUserId(@Param("userId") Long userId, @Param("date") LocalDate date,
                        Pageable pageable);

        @Query("SELECT wp FROM WorkPackage wp WHERE wp.dueDate < :date AND wp.workPackageStatus != 'COMPLETED'")
        Page<WorkPackage> findOverdue(@Param("date") LocalDate date, Pageable pageable);

        /**
         * counts the number of distinct Work Packages where a user is the accountable
         * or assignee person
         */
        @Query("SELECT COUNT(DISTINCT wp) FROM WorkPackage wp " +
                        "LEFT JOIN wp.accountable a " +
                        "LEFT JOIN wp.assignee ac " +
                        "WHERE a.id = :userId OR ac.id = :userId")
        long countAssignedWorkPackages(@Param("userId") Long userId);

        /**
         * Count all work packages where the specified user is specifically the
         * accountable person
         */
        @Query("SELECT COUNT(wp) FROM WorkPackage wp " +
                        "WHERE wp.accountable.id = :userId")
        long countAccountableWorkPackages(@Param("userId") Long userId);

        /**
         * Count all overdue work packages where the specified user is either the
         * assignee or the accountable person
         */
        @Query("SELECT COUNT(DISTINCT wp) FROM WorkPackage wp " +
                        "WHERE (wp.assignee.id = :userId OR wp.accountable.id = :userId) " +
                        "AND wp.dueDate < :date " +
                        "AND wp.workPackageStatus != 'COMPLETED'")
        long countAllOverdueByUserId(@Param("userId") Long userId, @Param("date") LocalDate date);

        /**
         * Count all work packages where the specified user is specifically the
         * assignee person
         */
        @Query("SELECT COUNT(wp) FROM WorkPackage wp " +
                        "WHERE wp.assignee.id = :userId")
        long countAssigneeWorkPackages(@Param("userId") Long userId);

        /**
         * counts overdue work packages where user is specifically the assignee
         * person
         */
        @Query("SELECT COUNT(wp) FROM WorkPackage wp " +
                        "WHERE wp.assignee.id = :userId " +
                        "AND wp.dueDate < :date " +
                        "AND wp.workPackageStatus != 'COMPLETED'")
        long countOverdueByAssigneeId(@Param("userId") Long userId, @Param("date") LocalDate date);

        /**
         * counts overdue work packages where user is specifically the accountable
         * person
         */
        @Query("SELECT COUNT(wp) FROM WorkPackage wp " +
                        "WHERE wp.accountable.id = :userId " +
                        "AND wp.dueDate < :date " +
                        "AND wp.workPackageStatus != 'COMPLETED'")
        long countOverdueByAccountableId(@Param("userId") Long userId, @Param("date") LocalDate date);

        @Query("SELECT COUNT(wp) FROM WorkPackage wp WHERE wp.dueDate < :date AND wp.workPackageStatus != 'COMPLETED'")
        long countOverdue(@Param("date") LocalDate date);

        @Query("SELECT wp FROM WorkPackage wp WHERE wp.project.id = :projectId ORDER BY wp.updatedAt DESC")
        Page<WorkPackage> findRecentByProjectId(@Param("projectId") Long projectId, Pageable pageable);

        @Query("SELECT wp FROM WorkPackage wp WHERE wp.project.id IN :projectIds ORDER BY wp.updatedAt DESC")
        Page<WorkPackage> findRecentByProjectIdIn(@Param("projectIds") List<Long> projectIds, Pageable pageable);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id = :projectId " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId) " +
                        "ORDER BY wp.updatedAt DESC")
        Page<WorkPackage> findRecentByProjectIdAndUserId(@Param("projectId") Long projectId,
                        @Param("userId") Long userId,
                        Pageable pageable);

        @Query("SELECT DISTINCT wp FROM WorkPackage wp " +
                        "WHERE wp.project.id IN :projectIds " +
                        "AND (wp.assignee.id = :userId OR wp.accountable.id = :userId) " +
                        "ORDER BY wp.updatedAt DESC")
        Page<WorkPackage> findRecentByProjectIdInAndUserId(@Param("projectIds") List<Long> projectIds,
                        @Param("userId") Long userId,
                        Pageable pageable);

        @Query("SELECT w.project.id FROM WorkPackage w WHERE w.id = :id")
        Optional<Long> findProjectIdById(@Param("id") Long id);

        boolean existsByIdAndAssigneeId(Long id, Long assigneeId);

        boolean existsByIdAndAccountableId(Long id, Long accountableId);
}
