<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="page-header mb-4">
    <h2 class="mb-1">Project Settings - ${project.name}</h2>
    <p class="text-muted mb-0">Manage project configuration and destructive actions.</p>
</div>

<div class="section-card mb-4" style="max-width:760px">
    <div class="section-heading mb-3">
        <span class="section-label"><i class="bi bi-sliders me-1"></i>General</span>
    </div>
    <dl class="row mb-0">
        <dt class="col-sm-3">Project</dt>
        <dd class="col-sm-9">${project.name}</dd>
        <dt class="col-sm-3">UI ID</dt>
        <dd class="col-sm-9">${not empty project.uiId ? project.uiId : '&mdash;'}</dd>
        <dt class="col-sm-3">Status</dt>
        <dd class="col-sm-9">
            <span class="chip chip-secondary">
                ${not empty project.projectStatus ? fn:replace(project.projectStatus, '_', ' ') : '&mdash;'}
            </span>
        </dd>
        <c:if test="${not empty project.parentName}">
            <dt class="col-sm-3">Parent</dt>
            <dd class="col-sm-9">${project.parentName}</dd>
        </c:if>
        <dt class="col-sm-3">Creator </dt>
        <dd class="col-sm-9">${project.creator != null ? project.creator : '&mdash;'}</dd>
        <dt class="col-sm-3">Created Date</dt>
        <dd class="col-sm-9">
            <c:choose>
                <c:when test="${project.createdAt != null}">
                    ${fn:replace(fn:substring(project.createdAt, 0, 16), 'T', ' ')}
                </c:when>
                <c:otherwise>&mdash;</c:otherwise>
            </c:choose>
        </dd>
    </dl>
    <div class="d-flex flex-wrap gap-2 mt-3">
        <a href="${pageContext.request.contextPath}/projects/${project.id}" class="btn btn-secondary">
            <i class="bi bi-arrow-left me-1"></i>Back to Project
        </a>
    </div>
</div>

<c:if test="${showAdminOption}">
    <div class="section-card" style="max-width:760px;background:var(--md-error-container);border-color:var(--md-error)">
        <h6 style="color:var(--md-on-error-container)">
            <i class="bi bi-exclamation-triangle me-2"></i>Danger Zone
        </h6>
        <p style="font-size:0.875rem;color:var(--md-on-error-container);opacity:0.9;margin-bottom:16px">
            Deleting this project is permanent and cannot be undone.
        </p>
        <button type="button" class="btn btn-danger btn-danger-strong"
            data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
            data-delete-action="${pageContext.request.contextPath}/projects/${project.id}/delete"
            data-delete-message="Permanently delete project '${project.name}'? This action cannot be undone.">
            <i class="bi bi-trash me-1"></i>Delete Project
        </button>
    </div>
</c:if>

<%@ include file="../layout/footer.jsp" %>
