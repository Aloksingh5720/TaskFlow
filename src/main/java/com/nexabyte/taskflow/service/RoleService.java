package com.nexabyte.taskflow.service;

import java.util.List;

import com.nexabyte.taskflow.dto.role.RoleDto;

public interface RoleService {

    List<RoleDto> getAllProjectRoles();

    List<RoleDto> getAssignableGlobalRoles(Long userId);
}
