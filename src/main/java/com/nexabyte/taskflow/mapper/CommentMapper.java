package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.comment.CommentDto;
import com.nexabyte.taskflow.entities.Comment;

public class CommentMapper {

    public static CommentDto toDto(Comment comment) {

        return CommentDto.builder()
                .id(comment.getId())
                .workPackageId(comment.getWorkPackage().getId())
                .workPackageSubject(comment.getWorkPackage().getSubject())
                .userId(comment.getUser().getId())
                .username(comment.getUser().getUsername())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .updatedAt(comment.getUpdatedAt())
                .build();
    }
}
