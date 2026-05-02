package com.nexabyte.taskflow.service.impl;

import java.util.List;
import java.util.Set;

import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.dto.role.RoleDto;
import com.nexabyte.taskflow.entities.Role;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.RoleMapper;
import com.nexabyte.taskflow.repository.RoleRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.service.RoleService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

        private final RoleRepository roleRepository;
        private final UserRepository userRepository;

        private static final Set<String> GLOBAL_ROLE_NAMES = Set.of(
                        GlobalRole.ADMIN,
                        GlobalRole.USER);

        private static final Set<String> PROJECT_ROLE_NAMES = Set.of(
                        ProjectRole.MANAGER,
                        ProjectRole.MEMBER,
                        ProjectRole.VIEWER);

        @Override
        public List<RoleDto> getAllProjectRoles() {
                List<Role> roles = roleRepository.findAll();
                return roles.stream()
                                .map(RoleMapper::toDto)
                                .filter(role -> PROJECT_ROLE_NAMES.contains(role.getName()))
                                .toList();
        }

        @Override
        public List<RoleDto> getAssignableGlobalRoles(Long userId) {

                User user = userRepository.findById(userId).orElseThrow(() -> {
                        throw new ResourceNotFoundException("User", "userId", userId.toString());
                });

                String globalRoleName = user.getGlobalRole().getName();

                if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
                        List<Role> roles = roleRepository.findByNameIn(GLOBAL_ROLE_NAMES);
                        return roles.stream()
                                        .map(RoleMapper::toDto)
                                        .toList();
                }

                List<Role> roles = roleRepository.findByNameIn(Set.of(GlobalRole.USER));
                return roles.stream()
                                .map(RoleMapper::toDto)
                                .toList();
        }
}
