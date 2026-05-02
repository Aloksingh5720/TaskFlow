<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="d-flex align-items-start justify-content-between flex-wrap gap-3 mb-4 py-3 border-bottom page-header">
    <div>
        <div class="d-flex align-items-center gap-3 mb-2 flex-wrap">
            <h2 class="mb-0">${workPackage.subject}</h2>
            <span class="chip chip-surface">${fn:replace(workPackage.workPackageType.name(), '_', ' ')}</span>
            <span class="chip chip-secondary">${fn:replace(workPackage.workPackageStatus.name(), '_', ' ')}</span>
        </div>
        <div class="d-flex align-items-center text-muted fs-6 gap-3 flex-wrap">
            <span><i class="bi bi-hash"></i>${not empty workPackage.uiId ? workPackage.uiId : workPackage.id}</span>
            <span>&bull;</span>
            <span>
                <i class="bi bi-folder2-open me-2"></i>
                <a href="${pageContext.request.contextPath}/projects/${workPackage.projectId}" class="text-decoration-none">${projectName}</a>
                <small class="ms-2 text-muted">(${not empty workPackage.projectUiId ? workPackage.projectUiId : workPackage.projectId})</small>
            </span>
        </div>
    </div>
    <div class="d-flex flex-wrap gap-2 mt-2 mt-md-0">
        <c:if test="${showAdminOption}">
            <a href="${pageContext.request.contextPath}/work-packages/${workPackage.id}/edit"
                class="btn btn-warning shadow-sm">
                <i class="bi bi-pencil me-2"></i>Edit
            </a>
        </c:if>
        <a href="${pageContext.request.contextPath}/work-packages/project/${workPackage.projectId}"
            class="btn btn-outline-primary shadow-sm">
            <i class="bi bi-arrow-left me-2"></i>Back
        </a>
    </div>
</div>

<div class="row g-4">
    <!-- Main Content Stream (Left) -->
    <div class="col-lg-8">
        <!-- Description -->
        <div class="section-card mb-4 shadow-sm border-0">
            <span class="section-label d-block border-bottom pb-2 mb-3"><i class="bi bi-card-text me-2"></i>Description</span>
            <c:choose>
                <c:when test="${not empty workPackage.description}">
                    <div class="mt-2 mb-0 content-text">
                        ${workPackage.description}
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="mt-2 mb-0 content-text-muted">
                        No description provided.
                    </p>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Attachments -->
        <div class="section-card mb-4 shadow-sm border-0">
            <div class="section-heading border-bottom pb-2 mb-3">
                <span class="section-label"><i class="bi bi-paperclip me-2"></i>Attachments</span>
            </div>
            <%@ include file="../attachment/_upload.jsp" %>
            <c:if test="${not empty attachments}">
                <div class="list-group mt-3 list-group-flush">
                    <c:forEach items="${attachments}" var="att">
                        <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-3">
                                <i class="bi bi-file-earmark-text fs-4 text-primary"></i>
                                <span class="fw-semibold">${att.fileName}</span>
                            </div>
                            <div class="d-flex align-items-center gap-2 flex-wrap">
                                <a href="${pageContext.request.contextPath}/work-packages/${workPackage.id}/attachments/${att.id}/file"
                                    class="btn btn-sm btn-outline-primary rounded-pill px-3"
                                    target="_blank"
                                    rel="noopener noreferrer">
                                    <i class="bi bi-eye me-1"></i>View
                                </a>
                                <a href="${pageContext.request.contextPath}/work-packages/${workPackage.id}/attachments/${att.id}/download"
                                    class="btn btn-sm btn-outline-primary rounded-pill px-3">
                                    <i class="bi bi-download me-1"></i>Download
                                </a>
                                <button type="button" class="btn btn-sm btn-outline-primary rounded-pill px-3"
                                    data-bs-toggle="modal"
                                    data-bs-target="#deleteConfirmModal"
                                    data-delete-action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/attachments/${att.id}/delete"
                                    data-delete-message="Are you sure you want to delete attachment '${att.fileName}'? This action cannot be undone.">
                                    <i class="bi bi-trash me-1"></i>Delete
                                </button>
                            </div>
                        </li>
                    </c:forEach>
                </div>
            </c:if>
            <c:if test="${empty attachments}">
                <div class="text-center py-4 px-2 text-muted bg-light rounded mt-3 border border-dashed">
                    <i class="bi bi-file-earmark-x d-block fs-3 mb-2"></i>
                    No attachments uploaded.
                </div>
            </c:if>
        </div>

        <!-- Time Entries -->
        <div class="section-card mb-4 shadow-sm border-0">
            <div class="section-heading border-bottom pb-2 mb-3 d-flex justify-content-between align-items-center flex-wrap gap-3">
                <span class="section-label"><i class="bi bi-clock-history me-2"></i>Time Entries</span>
                <button type="button" class="btn btn-sm btn-success shadow-sm" data-bs-toggle="modal" data-bs-target="#createTimeEntryModal">
                    <i class="bi bi-plus-lg me-1"></i> Log Time
                </button>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-3 py-3">Date</th>
                            <th class="py-3">User</th>
                            <th class="py-3">Hours</th>
                            <th class="py-3">Comment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${timeEntries}" var="te">
                            <tr>
                                <td class="ps-3 text-nowrap text-muted"><i class="bi bi-calendar3 me-2"></i>${te.spentOn}</td>
                                <td class="fw-medium">${te.username}</td>
                                <td><span class="badge bg-secondary px-2 py-1 fs-6">${te.hours}h</span></td>
                                <td class="text-muted pe-3">${te.comment}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty timeEntries}">
                            <tr>
                                <td colspan="4" class="text-center py-5 text-muted bg-light border-bottom-0">
                                    <i class="bi bi-clock d-block fs-3 mb-2 text-secondary"></i>
                                    No time logged yet.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Issues -->
        <!-- <div class="section-card mb-4 shadow-sm border-0">
            <div class="section-heading border-bottom pb-2 mb-3 d-flex justify-content-between align-items-center flex-wrap gap-3">
                <span class="section-label fs-5 fw-bold text-dark"><i class="bi bi-exclamation-octagon me-2 text-danger"></i>Issues</span>
                <c:if test="${workPackage.assigneeId == currentUserId}">
                    <button type="button" class="btn btn-sm btn-danger px-3 shadow-sm fw-bold" data-bs-toggle="modal" data-bs-target="#createIssueModal">
                        <i class="bi bi-plus-lg me-1"></i> Raise Issue
                    </button>
                </c:if>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-muted">
                        <tr>
                            <th class="ps-3 py-3 w-50">Title</th>
                            <th class="py-3">Status</th>
                            <th class="text-end pe-3 py-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${issues}" var="issue">
                            <tr>
                                <td class="ps-3 fw-medium text-dark">${issue.title}</td>
                                <td>
                                    <span class="badge ${issue.issueStatus.name() == 'RESOLVED' ? 'bg-success' : 'bg-warning text-dark'} px-2 py-1">
                                        ${fn:replace(issue.issueStatus.name(), '_', ' ')}
                                    </span>
                                </td>
                                <td class="text-end pe-3">
                                    <div class="btn-group shadow-sm">
                                        <button type="button" class="btn btn-sm btn-outline-info" title="View Details"
                                                data-bs-toggle="modal" data-bs-target="#issueDetailModal"
                                                data-title="${issue.title}" data-description="${issue.description}">
                                            <i class="bi bi-info-circle"></i><span class="d-none d-sm-inline ms-1">View</span>
                                        </button>
                                        <c:if test="${issue.issueStatus.name() != 'RESOLVED' && workPackage.accountableId == currentUserId}">
                                            <form action="${pageContext.request.contextPath}/issues/${issue.id}/resolve" method="post" class="d-inline mb-0">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                <button type="submit" class="btn btn-sm btn-outline-success border-start-0" title="Mark as Resolved">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty issues}">
                            <tr>
                                <td colspan="3" class="text-center py-5 text-muted bg-light border-bottom-0">
                                    <i class="bi bi-shield-check d-block fs-3 mb-2 text-success"></i>
                                    No issues raised.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div> -->

        <!-- Comments -->
        <div class="section-card shadow-sm border-0 mb-4">
            <span class="section-label d-block border-bottom pb-2 mb-4"><i class="bi bi-chat-dots me-2"></i>Comments</span>
            <div id="comments" class="mb-4">
                <c:forEach items="${comments}" var="comment">
                    <div class="d-flex mb-4">
                        <div class="flex-shrink-0 me-3">
                            <div class="avatar avatar-lg avatar-primary shadow-sm">
                                ${comment.username.substring(0,1).toUpperCase()}
                            </div>
                        </div>
                        <div class="flex-grow-1 bg-light rounded p-4 position-relative border">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="mb-0 fs-6">${comment.username}</h6>
                                <div class="d-flex align-items-center gap-3">
                                    <small class="text-muted"><i class="bi bi-clock me-1"></i>${fn:replace(fn:substring(comment.createdAt, 0, 16), 'T', ' ')}</small>
                                    <c:if test="${comment.userId == currentUserId}">
                                        <button type="button" class="btn btn-sm btn-link text-danger p-0 m-0 border-0 text-decoration-none" title="Delete Comment"
                                            data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                            data-delete-action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/comments/${comment.id}/delete"
                                            data-delete-message="Are you sure you want to delete this comment?">
                                            <i class="bi bi-trash fs-5"></i>
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                            <div class="content-text">${comment.content}</div>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty comments}">
                    <div class="text-center py-5 text-muted bg-light rounded border border-dashed border-light">
                        <i class="bi bi-chat-square-text d-block fs-3 mb-2 text-secondary"></i>
                        No comments yet. Be the first to start the conversation!
                    </div>
                </c:if>
            </div>
            
            <div class="mt-4 pt-4 border-top">
                <%@ include file="../comment/_form.jsp" %>
            </div>
        </div>
    </div>

    <!-- Sidebar (Right) -->
    <div class="col-lg-4">
        <!-- Details Card -->
        <div class="section-card shadow-sm border-0 mb-4 p-0">
            <div class="bg-light border-bottom p-3 rounded-top">
                <h6 class="mb-0 fs-6"><i class="bi bi-info-circle me-2"></i>Properties</h6>
            </div>
            <ul class="list-group list-group-flush rounded-bottom">
                <li class="list-group-item d-flex justify-content-between mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Project</span>
                    <a href="${pageContext.request.contextPath}/projects/${workPackage.projectId}" class="text-decoration-none fw-semibold pt-1">
                        ${workPackage.projectName}
                    </a>
                </li>
                <li class="list-group-item d-flex justify-content-between mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Type</span>
                    <span class="chip chip-surface">${fn:replace(workPackage.workPackageType.name(), '_', ' ')}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Status</span>
                    <span class="chip chip-secondary">${fn:replace(workPackage.workPackageStatus.name(), '_', ' ')}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Priority</span>
                    <c:choose>
                        <c:when test="${workPackage.workPackagePriority == 'HIGH' || workPackage.workPackagePriority == 'CRITICAL'}">
                            <span class="chip chip-error">${fn:replace(workPackage.workPackagePriority.name(), '_', ' ')}</span>
                        </c:when>
                        <c:when test="${workPackage.workPackagePriority == 'LOW'}">
                            <span class="chip chip-surface">${fn:replace(workPackage.workPackagePriority.name(), '_', ' ')}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="chip chip-warning">${fn:replace(workPackage.workPackagePriority.name(), '_', ' ')}</span>
                        </c:otherwise>
                    </c:choose>
                </li>
                <li class="list-group-item d-flex flex-column gap-1 mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Assignee</span>
                    <div class="d-flex align-items-center mt-1 inline-stack-sm">
                        <c:choose>
                            <c:when test="${not empty workPackage.assigneeName}">
                                <div class="avatar avatar-xs avatar-primary">
                                    ${workPackage.assigneeName.substring(0,1).toUpperCase()}
                                </div>
                                <span class="fw-medium">${workPackage.assigneeUsername}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="fw-medium text-muted">Unassigned</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </li>
                <li class="list-group-item d-flex flex-column gap-1 mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Accountable</span>
                    <div class="d-flex align-items-center mt-1 inline-stack-sm">
                        <c:choose>
                            <c:when test="${not empty workPackage.accountableName}">
                                <div class="avatar avatar-xs avatar-secondary">
                                    ${workPackage.accountableName.substring(0,1).toUpperCase()}
                                </div>
                                <span class="fw-medium">${workPackage.accountableUsername}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="fw-medium text-muted">Unassigned</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Est. Hours</span>
                    <span class="fw-medium">${workPackage.estimatedHours > 0 ? workPackage.estimatedHours : '-'}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center mx-2 px-1 py-3 border-bottom-dashed">
                    <span class="text-label-sm">Due Date</span>
                    <span class="fw-medium">${not empty workPackage.dueDate ? workPackage.dueDate : '-'}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center mx-2 px-1 py-3 border-bottom-0">
                    <span class="text-label-sm">Created At</span>
                    <span class="fw-medium">${not empty workPackage.createdAt ? fn:replace(fn:substring(workPackage.createdAt, 0, 16), 'T', ' ') : '-'}</span>
                </li>
            </ul>
        </div>

        <!-- Actions Sidebar (Admin only) -->
        <c:if test="${showAdminOption}">
            <div class="section-card shadow-sm border-0 border-top border-danger border-3 p-0 mt-4">
                <div class="p-3 bg-white rounded">
                    <span class="section-label d-block mb-3 fs-6 fw-bold text-danger"><i class="bi bi-shield-lock me-2"></i>Danger Zone</span>
                    <button type="button" class="btn btn-outline-danger w-100 fw-bold"
                        data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                        data-delete-action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/delete"
                        data-delete-message="Permanently delete work package ${not empty workPackage.uiId ? workPackage.uiId : workPackage.id} '${workPackage.subject}'? This action cannot be undone.">
                        <i class="bi bi-trash me-2"></i>Delete Package
                    </button>
                </div>
            </div>
        </c:if>
    </div>
</div>

<%@ include file="../issue/_create-modal.jsp" %>
<%@ include file="../timeentry/_create-modal.jsp" %>

<%@ include file="../layout/footer.jsp" %>

<!-- Issue Detail Modal -->
<div class="modal fade" id="issueDetailModal" tabindex="-1" aria-labelledby="issueDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content shadow">
      <div class="modal-header border-bottom-0">
        <h5 class="modal-title fw-bold text-dark" id="issueDetailModalLabel"><i class="bi bi-exclamation-octagon text-danger me-2"></i>Issue Details</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body py-2">
        <div class="mb-4">
            <label class="text-label-sm mb-1">Title</label>
            <p id="modalIssueTitle" class="fs-5 fw-medium mb-0"></p>
        </div>
        <div>
            <label class="text-label-sm mb-2">Description</label>
            <div id="modalIssueDescription" class="p-3 bg-light rounded text-prewrap"></div>
        </div>
      </div>
      <div class="modal-footer border-top-0 pt-0 mt-3">
        <button type="button" class="btn btn-secondary px-4 fw-medium shadow-sm" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var issueDetailModal = document.getElementById('issueDetailModal');
        if (issueDetailModal) {
            issueDetailModal.addEventListener('show.bs.modal', function (event) {
                var button = event.relatedTarget;
                var title = button.getAttribute('data-title');
                var description = button.getAttribute('data-description');
                
                var modalTitle = issueDetailModal.querySelector('#modalIssueTitle');
                var modalDescription = issueDetailModal.querySelector('#modalIssueDescription');

                if (modalTitle) modalTitle.textContent = title;
                if (modalDescription) modalDescription.textContent = description;
            });
        }
    });
</script>
