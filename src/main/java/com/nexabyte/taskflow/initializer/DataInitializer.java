package com.nexabyte.taskflow.initializer;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.ProjectMember;
import com.nexabyte.taskflow.entities.Role;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.repository.RoleRepository;
import com.nexabyte.taskflow.repository.ProjectRepository;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.UiIdGeneratorService;

import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DataInitializer {

    @Value("${app.taskflow.admin.username}")
    private String adminUsername;

    @Value("${app.taskflow.admin.password}")
    private String adminPassword;

    @Value("${app.taskflow.admin.email}")
    private String adminEmail;

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProjectRepository projectRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final WorkPackageRepository workPackageRepository;
    private final UiIdGeneratorService uiIdGeneratorService;
    private final PasswordEncoder passwordEncoder;

    @PostConstruct
    @Transactional
    public void initialize() {
        backfillProjectUiIds();
        backfillProjectMemberUiIds();
        backfillWorkPackageUiIds();

        /**
         * find role SUPER_ADMIN from role repository if not round then create it save
         * it as a role
         */
        Role superAdminRole = roleRepository.findByName(GlobalRole.SUPER_ADMIN)
                .orElseGet(() -> {
                    Role role = Role.builder()
                            .name(GlobalRole.SUPER_ADMIN)
                            .description("System Super Administrator")
                            .build();
                    return roleRepository.save(role);
                });

        if (!userRepository.existsByGlobalRole_Name(GlobalRole.SUPER_ADMIN)) {
            User superAdmin = User.builder()
                    .username(adminUsername)
                    .email(adminEmail)
                    .password(passwordEncoder.encode(adminPassword))
                    .name("System Administrator")
                    .enabled(true)
                    .globalRole(superAdminRole)
                    .build();
            userRepository.save(superAdmin);
        }
    }

    private void backfillProjectUiIds() {
        for (Project project : projectRepository.findByUiIdIsNull()) {
            project.setUiId(uiIdGeneratorService.generateProjectUiId(project.getId()));
        }
    }

    private void backfillWorkPackageUiIds() {
        for (WorkPackage workPackage : workPackageRepository.findByUiIdIsNull()) {
            workPackage.setUiId(uiIdGeneratorService.generateWorkPackageUiId(workPackage.getId()));
        }
    }

    private void backfillProjectMemberUiIds() {
        for (ProjectMember projectMember : projectMemberRepository.findByUiIdIsNull()) {
            projectMember.setUiId(uiIdGeneratorService.generateMemberUiId(projectMember.getId()));
        }
    }
}
