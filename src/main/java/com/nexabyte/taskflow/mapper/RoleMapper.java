package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.role.RoleDto;
import com.nexabyte.taskflow.entities.Role;

public class RoleMapper {

    public static RoleDto toDto(Role role) {
        return RoleDto.builder()
                .id(role.getId())
                .name(role.getName())
                .description(role.getDescription())
                .build();
    }
}
