package com.nexabyte.taskflow.entities;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import com.nexabyte.taskflow.audit.Auditable;
import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@Builder
@Table(name = "work_packages")
@NoArgsConstructor
@AllArgsConstructor
public class WorkPackage extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "ui_id", unique = true, length = 16)
    private String uiId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    private Project project;

    @Enumerated(EnumType.STRING)
    private WorkPackageType workPackageType;

    @Enumerated(EnumType.STRING)
    private WorkPackageStatus workPackageStatus;

    @Enumerated(EnumType.STRING)
    private WorkPackagePriority workPackagePriority;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignee_id")
    private User assignee;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "accountable_id")
    private User accountable;

    @Column(nullable = false, length = 255)
    private String subject;

    @Lob
    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private BigDecimal estimatedHours;

    @Column(name = "due_date")
    private LocalDate dueDate;

    private LocalDateTime completedAt;

    @Builder.Default
    @OneToMany(mappedBy = "workPackage", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Comment> comments = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "workPackage", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<TimeEntry> timeEntries = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "workPackage", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Attachment> attachments = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "workPackage", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Issue> issues = new HashSet<>();
}
