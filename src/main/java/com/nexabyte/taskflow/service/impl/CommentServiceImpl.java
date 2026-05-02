package com.nexabyte.taskflow.service.impl;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nexabyte.taskflow.dto.comment.CommentDto;
import com.nexabyte.taskflow.entities.Comment;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.exception.AccessDeniedException;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.CommentMapper;
import com.nexabyte.taskflow.repository.CommentRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.ActivityService;
import com.nexabyte.taskflow.service.CommentService;
import com.nexabyte.taskflow.utils.SecurityUtils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class CommentServiceImpl implements CommentService {

    private final CommentRepository commentRepository;
    private final WorkPackageRepository workPackageRepository;
    private final UserRepository userRepository;
    private final ActivityService activityService;

    @Override
    public CommentDto addComment(Long workPackageId, CommentDto commentDto, Long userId) {
        User currentUser = SecurityUtils.getCurrentUser();

        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        WorkPackage workPackage = workPackageRepository.findById(workPackageId).orElseThrow(() -> {
            return new ResourceNotFoundException("Workpackage", "workPackageId", workPackageId.toString());
        });

        Comment comment = Comment.builder()
                .workPackage(workPackage)
                .user(user)
                .content(commentDto.getContent())
                .build();

        Comment savedComment = commentRepository.save(comment);
        activityService.recordCommentAdded(CommentMapper.toDto(savedComment), currentUser.getUsername());
        return CommentMapper.toDto(comment);
    }

    @Override
    public CommentDto updateComment(Long commentId, CommentDto commentDto, Long userId) {

        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found"));
        if (!comment.getUser().getId().equals(userId)) {
            throw new AccessDeniedException("You can only edit your own comments");
        }
        comment.setContent(commentDto.getContent());
        comment = commentRepository.save(comment);

        return CommentMapper.toDto(comment);
    }

    @Override
    public void deleteComment(Long commentId, Long userId) {

        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found"));
        if (!comment.getUser().getId().equals(userId)) {
            throw new AccessDeniedException("You can only delete your own comments");
        }
        commentRepository.delete(comment);
    }

    @Override
    public Page<CommentDto> getCommentsForWorkPackage(Long workPackageId, Pageable pageable) {

        return commentRepository.findByWorkPackageId(workPackageId, pageable)
                .map(CommentMapper::toDto);
    }
}
