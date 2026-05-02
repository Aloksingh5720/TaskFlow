<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4 page-header">
            <div>
                <h2 class="mb-1">Project Members &mdash; ${project.name}</h2>
            </div>
            <div class="d-flex flex-wrap gap-2">
                <c:if test="${canManageProjectActions}">
                    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addMemberModal">
                        <i class="bi bi-person-plus"></i> Add Member
                    </button>
                </c:if>
                <a href="${pageContext.request.contextPath}/projects/${project.id}" class="btn btn-secondary">
                    <i class="bi bi-arrow-left me-1"></i>Project
                </a>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
            <div class="search-container search-compact">
                <form method="get" action="${pageContext.request.contextPath}/projects/${project.id}/members" class="search-container__form">
                    <input type="hidden" name="page" value="0" />
                    <div class="search-container__row" style="align-items: center;">
                        <div class="search-container__group" style="max-width: 520px;">
                            <div class="search-input-wrapper">
                                <i class="bi bi-search search-input-icon"></i>
                                <input type="text" name="search" value="${search}" class="search-input"
                                    placeholder="Search by member ID, username or email" />
                                <c:if test="${not empty search}">
                                    <button type="button" class="search-input-clear" onclick="document.getElementById('search').value='';this.closest('form').submit();">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </c:if>
                            </div>
                        </div>
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <button type="submit" class="btn btn-outline-primary search-btn" style="height: 40px;">
                                <i class="bi bi-search"></i> Search
                            </button>
                            <c:if test="${not empty search}">
                                <a class="btn btn-primary"
                                    href="${pageContext.request.contextPath}/projects/${project.id}/members" style="height: 40px;">
                                    <i class="bi bi-x-circle"></i> Clear
                                </a>
                            </c:if>
                        </div>
                    </div>
                </form>
            </div>
            <div class="px-3">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th style="width:140px">Member ID</th>
                            <th>Member</th>
                            <th>Email</th>
                            <th>Roles</th>
                            <c:if test="${canManageProjectActions}">
                                <th style="width:120px">Actions</th>
                            </c:if>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${members.content}" var="member">
                            <tr>
                                <td class="text-muted small fw-semibold">${not empty member.uiId ? member.uiId : member.id}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="kpi-icon primary rounded-circle" style="width: 32px; height: 32px; font-size: 0.82rem;">
                                            ${member.username.substring(0,1).toUpperCase()}
                                        </span>
                                        <div>
                                            <div class="fw-500">${member.username}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-muted">${member.email}</td>
                                <td>
                                    <div class="d-flex flex-wrap gap-1">
                                        <span class="badge rounded-pill text-bg-secondary">${member.role}</span>
                                    </div>
                                </td>
                                <c:if test="${canManageProjectActions}">
                                    <td>
                                        <div class="d-flex gap-2">
                                            <button type="button" class="btn btn-sm btn-warning" title="Edit Roles"
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
                                <td colspan="${canManageProjectActions ? 5 : 4}" class="empty-state">
                                    ${not empty search ? 'No matching members found.' : 'No members yet.'}
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            </div>
        </div>

        <c:if test="${members.totalPages > 1}">
            <c:url var="prevPageUrl" value="/projects/${project.id}/members">
                <c:param name="page" value="${members.number - 1}" />
                <c:param name="size" value="${members.size}" />
                <c:param name="sort" value="${empty param.sort ? 'createdAt,desc' : param.sort}" />
                <c:param name="search" value="${search}" />
            </c:url>
            <c:url var="nextPageUrl" value="/projects/${project.id}/members">
                <c:param name="page" value="${members.number + 1}" />
                <c:param name="size" value="${members.size}" />
                <c:param name="sort" value="${empty param.sort ? 'createdAt,desc' : param.sort}" />
                <c:param name="search" value="${search}" />
            </c:url>

            <nav aria-label="Project members pagination" class="d-flex align-items-center justify-content-between flex-wrap gap-3 mt-3">
                <div class="small text-muted">
                    Showing ${members.numberOfElements} of ${members.totalElements} members
                </div>
                <div class="d-flex align-items-center gap-2">
                    <a class="btn btn-outline-secondary btn-sm ${members.first ? 'disabled' : ''}"
                        href="${members.first ? '#' : prevPageUrl}"
                        aria-label="Previous page">
                        <i class="bi bi-chevron-left"></i>
                        Previous
                    </a>
                    <span class="small text-muted px-2">
                        Page ${members.number + 1} of ${members.totalPages}
                    </span>
                    <a class="btn btn-outline-secondary btn-sm ${members.last ? 'disabled' : ''}"
                        href="${members.last ? '#' : nextPageUrl}"
                        aria-label="Next page">
                        Next
                        <i class="bi bi-chevron-right"></i>
                    </a>
                </div>
            </nav>
        </c:if>

        <c:if test="${canManageProjectActions}">
            <%@ include file="_add-member-modal.jsp" %>
            <%@ include file="_edit-member-modal.jsp" %>
        </c:if>

        <%@ include file="../layout/footer.jsp" %>
