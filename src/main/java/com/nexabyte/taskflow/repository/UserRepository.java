package com.nexabyte.taskflow.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

        boolean existsByUsername(String username);

        boolean existsByEmail(String email);

        boolean existsByGlobalRole_Name(String roleName);

        Optional<User> findByUsername(String username);

        Optional<User> findByEmail(String email);

        Page<User> findByGlobalRole_NameNot(String excludedRole, Pageable pageable);

        @Query("SELECT u FROM User u WHERE u.id NOT IN " +
                        "(SELECT pm.user.id FROM ProjectMember pm WHERE pm.project.id = :projectId)")
        List<User> findUsersNotInProject(@Param("projectId") Long projectId);

        @Query("SELECT pm.user FROM ProjectMember pm " +
               "WHERE pm.project.id = :parentId " +
               "AND pm.user.id NOT IN (SELECT cpm.user.id FROM ProjectMember cpm WHERE cpm.project.id = :childId)")
        List<User> findUsersInParentButNotInChild(@Param("parentId") Long parentId, @Param("childId") Long childId);

        @Query(value = "SELECT u FROM User u WHERE " +
                        "(LOWER(u.username) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
                        "LOWER(u.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
                        "LOWER(u.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND " +
                        "u.globalRole.name != :excludedRole")
        Page<User> searchUsersExcludingRole(
                        @Param("searchTerm") String searchTerm,
                        @Param("excludedRole") String excludedRole,
                        Pageable pageable);
}
