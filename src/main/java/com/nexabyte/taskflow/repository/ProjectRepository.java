package com.nexabyte.taskflow.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.Project;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {

        boolean existsByUiId(String uiId);

        List<Project> findByUiIdIsNull();

        Page<Project> findByArchivedFalseAndParentIsNull(Pageable pageable);

        // count all the non-archived projects
        long countByArchivedFalse();

        // count all the non-archived parent projects (excluding child projects)
        long countByArchivedFalseAndParentIsNull();

        // Retrieves all non-archived projects where the specified user is a member.
        @Query("SELECT DISTINCT p FROM Project p LEFT JOIN p.projectMembers pm WHERE p.archived = false AND p.parent IS NULL AND pm.user.id = :userId")
        Page<Project> findAccessibleProjects(@Param("userId") Long userId, Pageable pageable);

        @Query("""
                        SELECT p FROM Project p
                        WHERE p.archived = false
                          AND p.parent IS NULL
                          AND (
                                LOWER(p.uiId) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                                OR LOWER(p.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                                OR STR(p.id) LIKE CONCAT('%', :searchTerm, '%')
                              )
                        """)
        Page<Project> searchActiveProjects(@Param("searchTerm") String searchTerm, Pageable pageable);

        @Query("""
                        SELECT DISTINCT p FROM Project p
                        LEFT JOIN p.projectMembers pm
                        WHERE p.archived = false
                          AND p.parent IS NULL
                          AND pm.user.id = :userId
                          AND (
                                LOWER(p.uiId) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                                OR LOWER(p.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                                OR STR(p.id) LIKE CONCAT('%', :searchTerm, '%')
                              )
                        """)
        Page<Project> searchAccessibleProjects(@Param("userId") Long userId,
                        @Param("searchTerm") String searchTerm,
                        Pageable pageable);

        /**
         * Get all non-archived projects where the specified user is a manager (without
         * pagination)
         */
        @Query("SELECT DISTINCT p FROM Project p JOIN p.projectMembers pm WHERE p.archived = false AND pm.user.id = :userId AND pm.role.name = 'MANAGER'")
        List<Project> findAllProjectsWhereUserIsManager(@Param("userId") Long userId);

        List<Project> findByParent(Project parent);

        List<Project> findByParentId(Long parentId);

        List<Project> findByParentIdIn(List<Long> parentIds);

        /**
         * Count all unique projects where user any role and project is not archived
         */
        @Query("SELECT COUNT(DISTINCT p) FROM Project p JOIN p.projectMembers pm WHERE pm.user.id = :userId AND p.archived = false")
        long countProjectsWhereUserHasAnyRoleIncludingChild(@Param("userId") Long userId);

        /**
         * Count all unique parent projects where user has any role and project is not
         * archived
         * (Excludes child/sub-projects)
         */
        @Query("SELECT COUNT(DISTINCT p) FROM Project p JOIN p.projectMembers pm WHERE pm.user.id = :userId AND p.archived = false AND p.parent IS NULL")
        long countProjectsWhereUserHasAnyRoleNotIncludingChild(@Param("userId") Long userId);

        /**
         * count all unique projects where user is a manager and project is not archived
         */
        @Query("SELECT COUNT(DISTINCT p) FROM Project p JOIN p.projectMembers pm WHERE p.archived = false AND pm.user.id = :userId AND pm.role.name = 'MANAGER'")
        long countProjectsWhereUserIsManagerIncludingChild(@Param("userId") Long userId);

        /**
         * count all unique parent projects where user is a manager and project is not
         * archived
         */
        @Query("SELECT COUNT(DISTINCT p) FROM Project p JOIN p.projectMembers pm WHERE p.archived = false AND p.parent IS NULL AND pm.user.id = :userId AND pm.role.name = 'MANAGER'")
        long countProjectsWhereUserIsManagerNotIncludingChild(@Param("userId") Long userId);

        @Query("SELECT DISTINCT p FROM Project p " +
                        "JOIN p.projectMembers pm " +
                        "WHERE p.parent.id = :parentId " +
                        "AND p.archived = false " +
                        "AND pm.user.id = :userId")
        List<Project> findAccessibleSubprojectsByParentId(@Param("userId") Long userId,
                        @Param("parentId") Long parentId);

        @Query("""
                        SELECT p.id FROM Project p
                        WHERE p.id = :projectId
                           OR p.parent.id = :projectId
                        """)
        List<Long> findProjectIdAndChildIds(@Param("projectId") Long projectId);
}
