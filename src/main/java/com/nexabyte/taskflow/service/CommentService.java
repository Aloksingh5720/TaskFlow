package com.nexabyte.taskflow.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.nexabyte.taskflow.dto.comment.CommentDto;

public interface CommentService {

    CommentDto addComment(Long workPackageId, CommentDto commentDto, Long userId);

    CommentDto updateComment(Long commentId, CommentDto commentDto, Long userId);

    void deleteComment(Long commentId, Long userId);

    Page<CommentDto> getCommentsForWorkPackage(Long workPackageId, Pageable pageable);
}