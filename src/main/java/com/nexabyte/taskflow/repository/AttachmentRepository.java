package com.nexabyte.taskflow.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.nexabyte.taskflow.entities.Attachment;

@Repository
public interface AttachmentRepository extends JpaRepository<Attachment, Long> {

    List<Attachment> findByWorkPackageId(Long workPackageId);
}
