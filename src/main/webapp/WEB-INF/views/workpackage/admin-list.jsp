<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4 page-header">
    <div>
        <h2 class="mb-1">${title != null ? title : 'Work Package Administration'}</h2>
        <p class="text-muted mb-0">Select a project to manage its work packages.</p>
    </div>
</div>

<c:choose>
    <c:when test="${showAdminOption}">
        <div class="section-card mb-4">
            <form method="get" action="${pageContext.request.contextPath}/work-packages" class="row g-3 align-items-end">
                <div class="col-lg-6 col-md-8">
                    <label for="projectId" class="form-label">Project</label>
                    <select name="projectId" id="projectId" class="form-select">
                        <option value="">Select a project</option>
                        <c:forEach items="${projects}" var="project">
                            <option value="${project.id}" ${selectedProjectId == project.id ? 'selected' : ''}>${project.name} (${not empty project.uiId ? project.uiId : project.id})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-lg-6 col-md-4 d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-search"></i> Show Work Packages
                    </button>
                    <c:if test="${not empty selectedProjectId}">
                        <a href="${pageContext.request.contextPath}/work-packages" class="btn btn-secondary">
                            <i class="bi bi-x-circle"></i> Clear
                        </a>
                    </c:if>
                </div>
            </form>
        </div>

        <c:choose>
            <c:when test="${empty selectedProjectId}">
                <div class="section-card empty-state">
                    <i class="bi bi-folder2-open"></i>
                    <p>Select a project to view its work packages.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="d-flex justify-content-end mb-3">
                    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createWorkPackageModal">
                        <i class="bi bi-plus-lg"></i> New Work Package
                    </button>
                </div>
                <div class="section-card">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 workpackage-table">
                            <thead>
                                <tr>
                                    <th class="col-id">#</th>
                                    <th>Subject</th>
                                    <th>Type</th>
                                    <th>Status</th>
                                    <th>Priority</th>
                                    <th>Assignee</th>
                                    <th>Accountable</th>
                                    <th class="col-date">Expected Date</th>
                                    <th class="col-actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${workPackages.content}" var="wp">
                                    <tr>
                                        <td class="table-cell-muted">${not empty wp.uiId ? wp.uiId : wp.id}</td>
                                        <td class="workpackage-subject">
                                            <a href="${pageContext.request.contextPath}/work-packages/${wp.id}" title="${wp.subject}">
                                                ${wp.subject}
                                            </a>
                                        </td>
                                        <td>
                                            <span class="chip chip-surface">${fn:replace(wp.workPackageType.name(), '_', ' ')}</span>
                                        </td>
                                        <td>
                                            <span class="chip chip-secondary">${fn:replace(wp.workPackageStatus.name(), '_', ' ')}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${wp.workPackagePriority.name() == 'HIGH' || wp.workPackagePriority.name() == 'CRITICAL'}">
                                                    <span class="chip chip-error">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span>
                                                </c:when>
                                                <c:when test="${wp.workPackagePriority.name() == 'LOW'}">
                                                    <span class="chip chip-surface">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="chip chip-warning">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="table-cell-muted">${not empty wp.assigneeUsername ? wp.assigneeUsername : '&mdash;'}</td>
                                        <td class="table-cell-muted">${not empty wp.accountableUsername ? wp.accountableUsername : '&mdash;'}</td>
                                        <td class="table-cell-muted col-date">${not empty wp.dueDate ? wp.dueDate : '&mdash;'}</td>
                                        <td>
                                            <div class="table-actions">
                                                <a href="${pageContext.request.contextPath}/work-packages/${wp.id}" class="btn btn-sm btn-secondary" title="View">
                                                    <i class="bi bi-eye"></i>
                                                </a>
                                                <button type="button" class="btn btn-sm btn-secondary" title="Raise Issue"
                                                    data-bs-toggle="modal" data-bs-target="#createIssueModal"
                                                    data-issue-action="${pageContext.request.contextPath}/work-packages/${wp.id}/issue">
                                                    <i class="bi bi-flag"></i>
                                                </button>
                                                <c:if test="${adminOptionByProjectId[wp.projectId]}">
                                                    <a href="${pageContext.request.contextPath}/work-packages/${wp.id}/edit" class="btn btn-sm btn-warning" title="Edit">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/work-packages/${wp.id}/delete" class="d-inline mb-0"
                                                          onsubmit="return confirm('Are you sure you want to delete this work package?');">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        <button type="submit" class="btn btn-sm btn-danger" title="Delete">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty workPackages.content}">
                                    <tr>
                                        <td colspan="9" class="text-center py-4 text-muted">
                                            No work packages found for the selected project.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>

        <c:if test="${showAdminOption}">
            <%@ include file="_create-modal.jsp" %>
        </c:if>
    </c:when>
    <c:otherwise>
        <div class="section-card empty-state">
            <i class="bi bi-shield-lock"></i>
            <p>You do not have permission to manage system work packages.</p>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="../issue/_create-modal.jsp" %>
<%@ include file="../layout/footer.jsp" %>
