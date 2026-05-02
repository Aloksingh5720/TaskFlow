package com.nexabyte.taskflow.repository;

import java.util.List;
import java.util.Set;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.ProjectMember;
import com.nexabyte.taskflow.entities.User;

@Repository
public interface ProjectMemberRepository extends JpaRepository<ProjectMember, Long> {

    boolean existsByUiId(String uiId);

    List<ProjectMember> findByUiIdIsNull();

    List<ProjectMember> findByProjectId(Long projectId);

    List<ProjectMember> findByUserId(Long userId);

    boolean existsByProjectIdAndUserId(Long projectId, Long userId);

    boolean existsByUserIdAndRole_NameIn(Long userId, List<String> roleNames);

    boolean existsByProjectIdAndUserIdAndRole_Name(Long projectId, Long userId, String roleName);

    boolean existsByProjectIdAndUserIdAndRole_NameIn(Long projectId, Long userId, List<String> roleNames);

    @Query("select pm.user from ProjectMember pm where pm.project.id = :projectId")
    Set<User> findUsersByProjectId(@Param("projectId") Long projectId);

    // Find recently added members with pagination control
    @Query("SELECT pm FROM ProjectMember pm WHERE pm.project.id = :projectId ORDER BY pm.createdAt DESC")
    Page<ProjectMember> findRecentlyAddedMembers(@Param("projectId") Long projectId, Pageable pageable);

    @Query("""
            SELECT pm
            FROM ProjectMember pm
            JOIN pm.user u
            WHERE pm.project.id = :projectId
              AND (
                    LOWER(pm.uiId) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                    OR LOWER(u.username) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                    OR LOWER(u.email) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
                    OR STR(pm.id) LIKE CONCAT('%', :searchTerm, '%')
                  )
            ORDER BY pm.createdAt DESC
            """)
    Page<ProjectMember> searchProjectMembers(@Param("projectId") Long projectId,
            @Param("searchTerm") String searchTerm,
            Pageable pageable);

    List<ProjectMember> findByUserIdAndRole_Name(Long userId, String roleName);
}
