package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.activity.ActivityDto;
import com.nexabyte.taskflow.entities.Activity;

public class ActivityMapper {

    public static ActivityDto toDto(Activity activity) {
        if (activity == null) {
            return null;
        }

        return ActivityDto.builder()
                .id(activity.getId())
                .description(activity.getDescription())
                .actor(activity.getActor())
                .createdAt(activity.getCreatedAt())
                .build();
    }
}
