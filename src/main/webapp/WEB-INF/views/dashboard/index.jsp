<%@include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<div class="align-items-center d-flex flex-wrap gap-3 justify-content-between mb-4 page-header">
    <div>
        <h2 class="mb-1">Workspace Overview</h2>
        <p class="mb-0 text-muted">
            Welcome back,
            <strong>
                <sec:authentication property="name" />
            </strong>
            . Here is the current delivery status.
        </p>
    </div>
    <sec:authorize access="hasAnyAuthority ('ROLE_ADMIN', 'ROLE_SUPER_ADMIN')">
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#dashboardCreateProjectModal">
            <i class="bi bi-plus-lg"></i>
            New Project
        </button>
    </sec:authorize>
</div>

<div class="mb-4 g-3 row">
    <div class="col-xl-3 col-md-6">
        <div class="kpi-card">
            <div class="kpi-head">
                <span>Projects</span>
                <span class="kpi-icon primary"><i class="bi bi-folder2-open"></i></span>
            </div>
            <div class="kpi-value">${projectCount != null ? projectCount : 0}</div>
            <p class="mb-3" style="font-size: 0.85rem; color: var(--md-on-surface-variant)">Total projects on your account</p>
            <a class="quick-link" href="${pageContext.request.contextPath}/projects">
                View projects
                <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="kpi-card">
            <div class="kpi-head">
                <span>Accountable Work</span>
                <span class="kpi-icon warning"><i class="bi bi-person-check"></i></span>
            </div>
            <div class="kpi-value">${accountableWorkPackageCount != null ? accountableWorkPackageCount : 0}</div>
            <p class="mb-3" style="font-size: 0.85rem; color: var(--md-on-surface-variant)">Work packages where you are accountable</p>
            <a class="quick-link" href="${pageContext.request.contextPath}/work-packages?accountable=me">
                View accountable work
                <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="kpi-card">
            <div class="kpi-head">
                <span>Assigned Work</span>
                <span class="kpi-icon success"><i class="bi bi-list-task"></i></span>
            </div>
            <div class="kpi-value">${assignedWorkPackageCount != null ? assignedWorkPackageCount : 0}</div>
            <p class="mb-3" style="font-size: 0.85rem; color: var(--md-on-surface-variant)">Work packages assigned to you</p>
            <a class="quick-link" href="${pageContext.request.contextPath}/work-packages?assignee=me">
                View assigned work
                <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="kpi-card">
            <div class="kpi-head">
                <span>Overdue</span>
                <span class="kpi-icon danger"><i class="bi bi-exclamation-triangle"></i></span>
            </div>
            <div class="kpi-value">${overdueCount != null ? overdueCount : 0}</div>
            <p class="mb-3" style="font-size: 0.85rem; color: var(--md-on-surface-variant)">Items past due date requiring escalation</p>
            <a class="quick-link" href="${pageContext.request.contextPath}/work-packages?overdue=true">
                Review overdue
                <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>
    </div>
</div>

<div class="section-card">
    <div class="section-heading">
        <h5 class="mb-0">
            <i class="bi bi-activity me-2" style="color: var(--md-primary)"></i>
            Recent Activity
        </h5>
        <span class="chip chip-surface">Live feed</span>
    </div>
    
    <c:choose>
        <c:when test="${empty activities}">
            <div class="py-4 text-center" style="color: var(--md-on-surface-variant)">
                <i class="bi bi-inbox" style="font-size: 2.5rem; opacity: 0.4"></i>
                <p class="mb-0 mt-2">No recent activity yet.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="table-responsive">
                <table class="mb-0 align-middle table table-hover">
                    <thead>
                        <tr>
                            <th>Type</th>
                            <th>Description</th>
                            <th>User</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${activities}" var="activity">
                            <tr>
                                <td>
                                    <c:choose>
                                        <c:when test="${activity.type eq 'CREATE'}">
                                            <span class="chip chip-success">CREATE</span>
                                        </c:when>
                                        <c:when test="${activity.type eq 'UPDATE'}">
                                            <span class="chip chip-primary">UPDATE</span>
                                        </c:when>
                                        <c:when test="${activity.type eq 'DELETE'}">
                                            <span class="chip chip-error">DELETE</span>
                                        </c:when>
                                        <c:when test="${activity.type eq 'STATUS'}">
                                            <span class="chip chip-warning">STATUS</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="chip chip-secondary">GENERAL</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${activity.description}</td>
                                <td>
                                    <span class="align-items-center d-flex gap-2">
                                        <span class="kpi-icon primary" style="width: 28px; height: 28px; font-size: 0.85rem; border-radius: 50%">
                                            ${activity.actorInitial}
                                        </span>
                                        ${activity.displayActor}
                                    </span>
                                </td>
                                <td style="white-space: nowrap; color: var(--md-on-surface-variant)">
                                    <c:choose>
                                        <c:when test="${not empty activity.formattedCreatedAt}">
                                            ${activity.formattedCreatedAt}
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<sec:authorize access="hasAnyAuthority ('ROLE_ADMIN', 'ROLE_SUPER_ADMIN')">
    <c:set var="createProjectModalId" value="dashboardCreateProjectModal" />
    <%@ include file="../project/_create-modal.jsp" %>
</sec:authorize>

<%@include file="../layout/footer.jsp" %>
