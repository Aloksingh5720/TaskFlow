package com.nexabyte.taskflow.service;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;
import com.nexabyte.taskflow.dto.gantt.GanttTaskDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;

public interface WorkPackageService {

        WorkPackageDto createWorkPackage(Long projectId, WorkPackageDto workPackageDto);

        WorkPackageDto updateWorkPackage(Long workPackageId, WorkPackageDto workPackageDto);

        WorkPackageDto updateClassification(Long workPackageId,
                        WorkPackageType type,
                        WorkPackageStatus status,
                        WorkPackagePriority priority);

        WorkPackageDto updateStatus(Long workPackageId, WorkPackageStatus status);

        void deleteWorkPackage(Long workPackageId);

        WorkPackageDto getWorkPackage(Long workPackageId);

        Page<WorkPackageDto> getAllWorkPackages(Pageable pageable);

        Page<WorkPackageDto> getAllWorkPackagesInProject(Long projectId, Pageable pageable);

        Page<WorkPackageDto> getLastNUpdatedWorkPackages(Long projectId, Pageable pageable);

        List<WorkPackageDto> getAllWorkPackagesByStatus(Long projectId, Long userId,
                        WorkPackageStatus workPackageStatus);

        List<WorkPackageDto> getAllWorkPackagesByStatusIncludingChildren(Long projectId,
                        WorkPackageStatus status);

        Page<WorkPackageDto> getWorkPackagesWithFilters(Long projectId,
                        String search,
                        WorkPackageType type,
                        WorkPackageStatus status,
                        WorkPackagePriority priority,
                        Long assigneeId,
                        Pageable pageable);

        List<GanttTaskDto> getProjectGanttTasks(Long projectId);

        Page<WorkPackageDto> getWorkPackagesByAssignee(Long userId, Pageable pageable);

        Page<WorkPackageDto> getWorkPackagesByAccountable(Long userId, Pageable pageable);

        Page<WorkPackageDto> getOverdueWorkPackages(Long userId, Pageable pageable);

        long countAssignedWorkPackages(Long userId);

        long countAccountableWorkPackages(Long userId);

        long countOverdueWorkPackages(Long userId);

}
