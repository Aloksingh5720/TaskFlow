<%@include file="../layout/header.jsp" %> <%@ taglib prefix="c" uri="jakarta.tags.core" %> <%@ taglib prefix="fn" uri="jakarta.tags.functions" %> <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-4 page-header">
    <div class="d-flex align-items-center gap-3">
        <div class="card-icon card-icon-lg card-icon-primary">
            <i class="bi bi-folder2-open"></i>
        </div>
        <div>
            <h2 class="mb-1">${project.name}</h2>
            <p class="mb-0 text-muted">${project.description}</p>
        </div>
    </div>
    <div class="d-flex gap-2 flex-wrap">
        <c:if test="${canManageProjectActions}">
            <button type="button" class="btn btn-warning"
                data-bs-toggle="modal" data-bs-target="#editProjectModal"
                data-edit-action="${pageContext.request.contextPath}/projects/${project.id}"
                data-project-name="${project.name}"
                data-project-description="${project.description}"
                data-project-parent-id="${project.parentId}"
                data-project-status="${project.projectStatus}">
                <i class="bi me-1 bi-pencil"></i>
                Edit
            </button>
        </c:if>
        <a href="${pageContext.request.contextPath}/projects" class="btn btn-outline-primary">
            <i class="bi me-1 bi-arrow-left"></i>
            Back
        </a>
    </div>
</div>
<div class="mb-4 g-4 project-overview-grid row">
    <div class="col-12">
        <div class="pv-card pv-card--details">
            <div class="pv-card__header">
                <div class="pv-card__icon pv-card__icon--primary"><i class="bi bi-clipboard-data"></i></div>
                <h5 class="pv-card__title">Project Overview</h5>
            </div>
            <div class="pv-card__body">
                <div class="pv-split">
                    <div class="pv-split__left">
                        <span class="pv-split__heading">
                            <i class="bi me-1 bi-info-circle"></i>
                            Details
                        </span>
                        <div class="pv-detail-grid">
                            <div class="pv-detail-row">
                                <span class="pv-detail-icon"><i class="bi bi-hash"></i></span>
                                <span class="pv-detail-label">Project ID</span>
                                <span class="pv-detail-value">
                                    <span class="chip chip-surface">${not empty project.uiId ? project.uiId : '&mdash;'}</span>
                                </span>
                            </div>
                            <div class="pv-detail-row">
                                <span class="pv-detail-icon"><i class="bi bi-flag"></i></span>
                                <span class="pv-detail-label">Status</span>
                                <span class="pv-detail-value">
                                    <c:choose>
                                        <c:when test="${canManageProjectActions}">
                                            <div class="dropdown">
                                                <c:choose>
                                                    <c:when test="${project.projectStatus == 'ON_TRACK' || project.projectStatus == 'FINISHED'}">
                                                        <c:set value="btn-success" var="currentStatusClass" />
                                                    </c:when>
                                                    <c:when test="${project.projectStatus == 'AT_RISK'}">
                                                        <c:set value="btn-warning" var="currentStatusClass" />
                                                    </c:when>
                                                    <c:when test="${project.projectStatus == 'OFF_TRACK' || project.projectStatus == 'DISCONTINUED'}">
                                                        <c:set value="btn-danger" var="currentStatusClass" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:set value="btn-secondary" var="currentStatusClass" />
                                                    </c:otherwise>
                                                </c:choose>
                                                <button class="btn btn-sm ${currentStatusClass} dropdown-toggle" type="button" aria-expanded="false" data-bs-toggle="dropdown">${fn:replace(project.projectStatus, '_', ' ')}</button>
                                                <ul class="dropdown-menu dropdown-menu-end">
                                                    <c:forEach items="${projectStatuses}" var="status">
                                                        <c:if test="${project.projectStatus != status}">
                                                            <li>
                                                                <form action="${pageContext.request.contextPath}/projects/${project.id}/change-status" method="post" class="mb-0">
                                                                    <input name="${_csrf.parameterName}" type="hidden" value="${_csrf.token}" />
                                                                    <input name="projectStatus" type="hidden" value="${status}" />
                                                                    <button class="dropdown-item" type="submit">${fn:replace(status, '_', ' ')}</button>
                                                                </form>
                                                            </li>
                                                        </c:if>
                                                    </c:forEach>
                                                </ul>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:choose>
                                                <c:when test="${project.projectStatus == 'ON_TRACK' || project.projectStatus == 'FINISHED'}">
                                                    <span class="chip chip-success">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:when>
                                                <c:when test="${project.projectStatus == 'AT_RISK'}">
                                                    <span class="chip chip-warning">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:when>
                                                <c:when test="${project.projectStatus == 'OFF_TRACK' || project.projectStatus == 'DISCONTINUED'}">
                                                    <span class="chip chip-error">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="chip chip-secondary">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <c:if test="${not empty project.parentName}">
                                <div class="pv-detail-row">
                                    <span class="pv-detail-icon"><i class="bi bi-diagram-2"></i></span>
                                    <span class="pv-detail-label">Parent Project</span>
                                    <span class="pv-detail-value">${project.parentName}</span>
                                </div>
                            </c:if>
                            <div class="pv-detail-row">
                                <span class="pv-detail-icon"><i class="bi bi-calendar-plus"></i></span>
                                <span class="pv-detail-label">Created Date</span>
                                <span class="pv-detail-value">
                                    <c:choose>
                                        <c:when test="${project.createdAt != null}">${fn:replace(fn:substring(project.createdAt, 0, 16), 'T', ' ')}</c:when>
                                        <c:otherwise>'&mdash;'</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="pv-detail-row">
                                <span class="pv-detail-icon"><i class="bi bi-diagram-2"></i></span>
                                <span class="pv-detail-label">Creator</span>
                                <span class="pv-detail-value">${project.creator != null ? project.creator : '&mdash;'}</span>
                            </div>
                            <c:if test="${not empty project.updatedAt}">
                                <div class="pv-detail-row">
                                    <span class="pv-detail-icon"><i class="bi bi-diagram-2"></i></span>
                                    <span class="pv-detail-label">Last Updated</span>
                                    <span class="pv-detail-value">
                                        ${fn:replace(fn:substring(project.updatedAt, 0, 16), 'T', ' ')}
                                    </span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    <div class="pv-split__right">
                        <span class="pv-split__heading">
                            <i class="bi me-1 bi-bar-chart-line"></i>
                            STATS
                        </span>
                        <div class="pv-stat-grid pv-stat-grid--vertical">
                            <a href="${pageContext.request.contextPath}/projects/${project.id}/members" class="pv-stat-item text-decoration-none">
                                <div class="pv-stat-icon pv-stat-icon--primary"><i class="bi bi-people-fill"></i></div>
                                <div class="pv-stat-info">
                                    <span class="pv-stat-number">${members.totalElements}</span>
                                    <span class="pv-stat-label">Members</span>
                                </div>
                            </a>
                            <a href="${pageContext.request.contextPath}/work-packages/project/${project.id}" class="pv-stat-item text-decoration-none">
                                <div class="pv-stat-icon pv-stat-icon--error"><i class="bi bi-check2-square"></i></div>
                                <div class="pv-stat-info">
                                    <span class="pv-stat-number">${workPackages.totalElements}</span>
                                    <span class="pv-stat-label">Work Packages</span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="mb-4 section-card">
    <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
        <span class="mb-0 section-label">
            <i class="bi me-1 bi-diagram-2"></i>
            Child Projects
        </span>
        <div class="d-flex align-items-center gap-2">
            <span class="chip chip-surface">${childProjectsCount}</span>
            <c:if test="${canManageProjectActions and empty project.parentId}">
                <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#childProjectCreateModal">
                    <i class="bi me-1 bi-plus-lg"></i>
                    New Child Project
                </button>
            </c:if>
        </div>
    </div>
    <c:choose>
        <c:when test="${empty childProjects}">
            <div class="text-muted">No child projects.</div>
        </c:when>
        <c:otherwise>
            <ul class="list-group list-group-flush">
                <c:forEach items="${childProjects}" var="child">
                    <li class="d-flex align-items-center justify-content-between list-group-item px-0">
                        <a href="${pageContext.request.contextPath}/projects/${child.id}">${child.name}</a>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </li>
                </c:forEach>
            </ul>
        </c:otherwise>
    </c:choose>
</div>
<c:if test="${canManageProjectActions}">
    <c:if test="${empty project.parentId}">
        <c:set var="createProjectModalId" value="childProjectCreateModal" />
        <%@ include file="_create-modal.jsp" %>
    </c:if>
    <%@ include file="_edit-modal.jsp" %>
    <%@ include file="_add-member-modal.jsp" %>
    <%@ include file="_edit-member-modal.jsp" %>
</c:if>
<c:if test="${canCreateWorkPackage}">
    <%@ include file="../workpackage/_create-modal.jsp" %>
</c:if>
<ul class="nav nav-tabs" id="projectTabs">
    <li class="nav-item">
        <a href="#workpackages" class="nav-link active" data-bs-toggle="tab">
            <i class="bi me-1 bi-check2-square"></i>
            Work Packages
        </a>
    </li>
    <li class="nav-item">
        <a href="#members" class="nav-link" data-bs-toggle="tab">
            <i class="bi me-1 bi-people"></i>
            Members
        </a>
    </li>
</ul>
<div class="tab-content">
    <div class="fade tab-pane active show" id="workpackages">
        <div class="d-flex align-items-center justify-content-between mb-3">
            <span class="section-label">Work Packages</span>
            <c:if test="${canCreateWorkPackage}">
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#createWorkPackageModal">
                        <i class="bi bi-plus-lg"></i>
                        New
                    </button>
                </div>
            </c:if>
        </div>
        <div class="table-responsive">
            <table class="mb-0 align-middle table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Subject</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Priority</th>
                        <th>Assignee</th>
                        <th>Expected Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${workPackages.content}" var="wp">
                        <c:set var="canUseWorkPackageActions" value="${showAdminOption or (currentUserId != null and wp.accountableId == currentUserId)}" />
                        <tr>
                            <td class="text-muted"><small>${not empty wp.uiId ? wp.uiId : wp.id}</small></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/work-packages/${wp.id}">${wp.subject}</a>
                            </td>
                            <td>
                                <span class="chip chip-surface">${wp.workPackageType}</span>
                            </td>
                            <td>
                                <span class="chip chip-secondary">${wp.workPackageStatus}</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${wp.workPackagePriority == 'HIGH' || wp.workPackagePriority == 'CRITICAL'}">
                                        <span class="chip chip-error">${wp.workPackagePriority}</span>
                                    </c:when>
                                    <c:when test="${wp.workPackagePriority == 'LOW'}">
                                        <span class="chip chip-surface">${wp.workPackagePriority}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="chip chip-warning">${wp.workPackagePriority}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted">${wp.assigneeName != null ? wp.assigneeName : '&mdash;'}</td>
                            <td class="text-muted" style="white-space: nowrap">${wp.dueDate != null ? wp.dueDate : '&mdash;'}</td>
                            <td>
                                <div class="table-actions">
                                    <c:if test="${canUseWorkPackageActions}">
                                        <a href="${pageContext.request.contextPath}/work-packages/${wp.id}/edit" class="btn btn-sm btn-warning" title="Edit Work Package">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${showAdminOption}">
                                        <button type="button" class="btn btn-sm btn-danger" title="Delete Work Package"
                                            data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                            data-delete-action="${pageContext.request.contextPath}/work-packages/${wp.id}/delete"
                                            data-delete-message="Are you sure you want to delete work package ${not empty wp.uiId ? wp.uiId : wp.id} '${wp.subject}'?">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty workPackages.content}">
                        <tr>
                            <td class="py-4 text-center text-muted" colspan="8">
                                No work packages yet.
                                <c:if test="${canCreateWorkPackage}">
                                    <button type="button" class="btn btn-link p-0 align-baseline" data-bs-toggle="modal" data-bs-target="#createWorkPackageModal">Add one</button>
                                </c:if>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
        <c:if test="${not empty workPackages.content}">
            <div class="pv-section-footer">
                <a href="${pageContext.request.contextPath}/work-packages/project/${project.id}" class="btn btn-outline-primary btn-sm">
                    View All
                </a>
            </div>
        </c:if>
    </div>
    <div class="fade tab-pane" id="members">
        <div class="d-flex align-items-center justify-content-between mb-3">
            <span class="section-label">Team Members</span>
            <c:if test="${canManageProjectActions}">
                <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addMemberModal">
                    <i class="bi bi-person-plus"></i>
                    Add Member
                </button>
            </c:if>
        </div>
        <div class="table-responsive">
            <table class="mb-0 align-middle table table-hover">
                <thead>
                    <tr>
                        <th>Member</th>
                        <th>Roles</th>
                        <c:if test="${canManageProjectActions}">
                            <th>Actions</th>
                        </c:if>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${members.content}" var="member">
                        <tr>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="avatar avatar-sm avatar-primary">${member.username.substring(0,1).toUpperCase()}</span>
                                    ${member.username}
                                </div>
                            </td>
                            <td>
                                <div class="d-flex flex-wrap gap-1">
                                    <span class="chip chip-secondary">${member.role}</span>
                                </div>
                            </td>
                            <c:if test="${canManageProjectActions}">
                                <td>
                                    <div class="d-flex gap-2">
                                        <button type="button" class="btn btn-sm btn-warning" title="Edit"
                                            data-bs-toggle="modal" data-bs-target="#editMemberModal"
                                            data-edit-action="${pageContext.request.contextPath}/projects/${project.id}/members/${member.id}"
                                            data-member-username="${member.username}"
                                            data-member-role-id="${member.roleId}">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger" title="Remove"
                                            data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                            data-delete-action="${pageContext.request.contextPath}/projects/${project.id}/members/${member.id}/delete"
                                            data-delete-message="Are you sure you want to remove '${member.username}' from this project?">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty members.content}">
                        <tr>
                            <td class="py-4 text-center text-muted" colspan="2">No members added yet.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
        <c:if test="${not empty members.content}">
            <div class="pv-section-footer">
                <a href="${pageContext.request.contextPath}/projects/${project.id}/members" class="btn btn-outline-primary btn-sm">
                    View All
                </a>
            </div>
        </c:if>
    </div>
    <div class="fade tab-pane" id="settings">
        <span class="section-label">Project Settings</span>
        <div class="section-card mt-3" style="background: var(--md-error-container); border-color: var(--md-error)">
            <h6 class="mb-3" style="color: var(--md-on-error-container)">
                <i class="bi bi-exclamation-triangle me-2"></i>
                Danger Zone
            </h6>
            <p class="mb-3" style="font-size: 0.875rem; color: var(--md-on-error-container); opacity: 0.85;">Deleting this project is permanent and cannot be undone.</p>
            <div class="d-flex gap-2 flex-wrap">
                <button type="button" class="btn btn-warning"
                    data-bs-toggle="modal" data-bs-target="#editProjectModal"
                    data-edit-action="${pageContext.request.contextPath}/projects/${project.id}"
                    data-project-name="${project.name}"
                    data-project-description="${project.description}"
                    data-project-parent-id="${project.parentId}"
                    data-project-status="${project.projectStatus}">
                    <i class="bi me-1 bi-pencil"></i>
                    Edit Project
                </button>
                <button type="button" class="btn btn-danger"
                    data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                    data-delete-action="${pageContext.request.contextPath}/projects/${project.id}/delete"
                    data-delete-message="Permanently delete project '${project.name}'? This action cannot be undone.">
                    <i class="bi me-1 bi-trash"></i>
                    Delete Project
                </button>
            </div>
        </div>
    </div>
</div>
<script>
    (function () {
        if (!window.location.hash || !window.bootstrap || !bootstrap.Tab) return;
        var trigger = document.querySelector('#projectTabs a[href="' + window.location.hash + '"]');
        if (!trigger) return;
        bootstrap.Tab.getOrCreateInstance(trigger).show();
    })();
</script>
<%@ include file="../layout/footer.jsp" %>
