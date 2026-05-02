package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.user.CreateUserDto;
import com.nexabyte.taskflow.entities.User;

public class UserMapper {

    public static CreateUserDto toDto(User user) {
        var globalRole = user.getGlobalRole();

        return CreateUserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .name(user.getName())
                .isEnabled(user.isEnabled())
                .globalRoleId(globalRole != null ? globalRole.getId() : null)
                .globalRole(globalRole != null ? globalRole.getName() : null)
                .build();
    }

    public static com.nexabyte.taskflow.dto.user.UpdateUserDto toUpdateDto(User user) {
        var globalRole = user.getGlobalRole();

        return com.nexabyte.taskflow.dto.user.UpdateUserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .name(user.getName())
                .isEnabled(user.isEnabled())
                .globalRoleId(globalRole != null ? globalRole.getId() : null)
                .globalRole(globalRole != null ? globalRole.getName() : null)
                .build();
    }
}
