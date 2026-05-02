<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<sec:authentication property="principal.username" var="currentUsername" />

<div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4 page-header">
    <div>
        <h2 class="mb-1">User Management</h2>
        <p class="text-muted mb-0">Manage active accounts and global role assignments.</p>
    </div>
    <div class="d-flex gap-2">
        <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#bulkUploadModal">
            <i class="bi bi-upload"></i> Bulk Import
        </button>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createUserModal">
            <i class="bi bi-person-plus"></i> New User
        </button>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <div class="search-container search-compact">
            <form method="get" action="${pageContext.request.contextPath}/admin/users" class="search-container__form">
                <input type="hidden" name="page" value="0" />
                <input type="hidden" name="sortField" value="${sortField}" />
                <input type="hidden" name="sortDir" value="${sortDir}" />
                <div class="search-container__row" style="align-items: center;">
                    <div class="search-container__group" style="max-width: 520px;">
                        <div class="search-input-wrapper">
                            <i class="bi bi-search search-input-icon"></i>
                            <input type="text" name="search" value="${search}" class="search-input"
                                placeholder="Search by username, email or name" />
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
                                href="${pageContext.request.contextPath}/admin/users?page=0&sortField=${sortField}&sortDir=${sortDir}" style="height: 40px;">
                                <i class="bi bi-x-circle"></i> Clear
                            </a>
                        </c:if>
                    </div>
                </div>
            </form>
        </div>

        <c:url var="sortIdUrl" value="/admin/users">
            <c:param name="page" value="${currentPage}" />
            <c:param name="sortField" value="id" />
            <c:param name="sortDir" value="${sortField == 'id' ? reverseSortDir : 'asc'}" />
            <c:param name="search" value="${search}" />
        </c:url>
        <c:url var="sortUsernameUrl" value="/admin/users">
            <c:param name="page" value="${currentPage}" />
            <c:param name="sortField" value="username" />
            <c:param name="sortDir" value="${sortField == 'username' ? reverseSortDir : 'asc'}" />
            <c:param name="search" value="${search}" />
        </c:url>
        <c:url var="sortEmailUrl" value="/admin/users">
            <c:param name="page" value="${currentPage}" />
            <c:param name="sortField" value="email" />
            <c:param name="sortDir" value="${sortField == 'email' ? reverseSortDir : 'asc'}" />
            <c:param name="search" value="${search}" />
        </c:url>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th style="width:50px">
                            <a href="${sortIdUrl}" class="text-decoration-none sort-link ${sortField == 'id' ? 'active' : ''}">
                                #
                                <i class="bi ${sortField == 'id' ? (sortDir == 'asc' ? 'bi-sort-up' : 'bi-sort-down') : 'bi-arrow-down-up'}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${sortUsernameUrl}" class="text-decoration-none sort-link ${sortField == 'username' ? 'active' : ''}">
                                Username
                                <i class="bi ${sortField == 'username' ? (sortDir == 'asc' ? 'bi-sort-up' : 'bi-sort-down') : 'bi-arrow-down-up'}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${sortEmailUrl}" class="text-decoration-none sort-link ${sortField == 'email' ? 'active' : ''}">
                                Email
                                <i class="bi ${sortField == 'email' ? (sortDir == 'asc' ? 'bi-sort-up' : 'bi-sort-down') : 'bi-arrow-down-up'}"></i>
                            </a>
                        </th>
                        <th>Status</th>
                        <th>Global Role</th>
                        <th style="width:110px">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users.content}" var="user">
                        <tr>
                            <td style="color:var(--md-on-surface-variant);font-size:0.8rem">${user.id}</td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="kpi-icon primary rounded-circle"
                                        style="width:32px;height:32px;font-size:0.85rem;flex-shrink:0">
                                        ${user.username.substring(0,1).toUpperCase()}
                                    </span>
                                    <div>
                                        <div class="fw-500">${user.username}</div>
                                        <div style="font-size:0.775rem;color:var(--md-on-surface-variant)">
                                            ${user.name}</div>
                                    </div>
                                </div>
                            </td>
                            <td style="color:var(--md-on-surface-variant)">${user.email}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${user.enabled}">
                                        <span class="badge rounded-pill text-bg-success">
                                            <i class="bi bi-check-circle"></i> Active
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge rounded-pill text-bg-danger">
                                            <i class="bi bi-x-circle"></i> Disabled
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="d-flex flex-wrap gap-1">
                                    <span class="badge rounded-pill text-bg-secondary">${user.globalRole}</span>
                                </div>
                            </td>
                            <td>
                                <div class="d-flex gap-2">
                                    <sec:authorize access="hasAuthority('ROLE_SUPER_ADMIN')">
                                        <button type="button"
                                            class="btn btn-sm btn-warning js-edit-user"
                                            title="Edit"
                                            data-bs-toggle="modal"
                                            data-bs-target="#editUserModal"
                                            data-user-id="${user.id}"
                                            data-username="${user.username}"
                                            data-name="${user.name}"
                                            data-email="${user.email}"
                                            data-enabled="${user.enabled}"
                                            data-global-role-id="${user.globalRoleId}">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger" title="Delete"
                                            data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                            data-delete-action="${pageContext.request.contextPath}/admin/users/${user.id}/delete"
                                            data-delete-message="Are you sure you want to delete user '${user.username}'? This action cannot be undone.">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </sec:authorize>
                                    <sec:authorize access="hasAuthority('ROLE_ADMIN')">
                                        <c:choose>
                                            <c:when test="${user.globalRole == 'USER' && user.username != currentUsername}">
                                                <button type="button"
                                                    class="btn btn-sm btn-warning js-edit-user"
                                                    title="Edit"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#editUserModal"
                                                    data-user-id="${user.id}"
                                                    data-username="${user.username}"
                                                    data-name="${user.name}"
                                                    data-email="${user.email}"
                                                    data-enabled="${user.enabled}"
                                                    data-global-role-id="${user.globalRoleId}">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <button type="button" class="btn btn-sm btn-danger" title="Delete"
                                                    data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                                    data-delete-action="${pageContext.request.contextPath}/admin/users/${user.id}/delete"
                                                    data-delete-message="Are you sure you want to delete user '${user.username}'? This action cannot be undone.">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </sec:authorize>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty users.content}">
                        <tr>
                            <td colspan="6" class="text-center py-4" style="color:var(--md-on-surface-variant)">
                                No users found.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<c:if test="${users.totalPages > 1}">
    <c:url var="prevPageUrl" value="/admin/users">
        <c:param name="page" value="${currentPage - 1}" />
        <c:param name="sortField" value="${sortField}" />
        <c:param name="sortDir" value="${sortDir}" />
        <c:param name="search" value="${search}" />
    </c:url>
    <c:url var="nextPageUrl" value="/admin/users">
        <c:param name="page" value="${currentPage + 1}" />
        <c:param name="sortField" value="${sortField}" />
        <c:param name="sortDir" value="${sortDir}" />
        <c:param name="search" value="${search}" />
    </c:url>

    <nav aria-label="Users pagination" class="d-flex align-items-center justify-content-between flex-wrap gap-3 mt-3">
        <div class="small text-muted">
            Showing ${users.numberOfElements} of ${users.totalElements} users
        </div>
        <div class="d-flex align-items-center gap-2">
            <a class="btn btn-outline-secondary btn-sm ${users.first ? 'disabled' : ''}"
                href="${users.first ? '#' : prevPageUrl}"
                aria-label="Previous page">
                <i class="bi bi-chevron-left"></i>
                Previous
            </a>
            <span class="small text-muted px-2">
                Page ${currentPage + 1} of ${users.totalPages}
            </span>
            <a class="btn btn-outline-secondary btn-sm ${users.last ? 'disabled' : ''}"
                href="${users.last ? '#' : nextPageUrl}"
                aria-label="Next page">
                Next
                <i class="bi bi-chevron-right"></i>
            </a>
        </div>
    </nav>
</c:if>

<%@ include file="_create-user-modal.jsp" %>
<%@ include file="_edit-user-modal.jsp" %>
<%@ include file="_bulk-upload-modal.jsp" %>

<script>
    (function () {
        var showCreateUserModal = "${showCreateUserModal}" === "true";
        var showEditUserModal   = "${showEditUserModal}"   === "true";
        var contextPath         = "${pageContext.request.contextPath}";

        var editUserModalElement = document.getElementById("editUserModal");
        var editUserForm = document.getElementById("editUserForm");

        function setEditUserFormState(trigger) {
            if (!editUserForm || !trigger) return;

            var userId = trigger.getAttribute("data-user-id");
            editUserForm.setAttribute("action", contextPath + "/admin/users/" + userId);

            var usernameInput = document.getElementById("editUserUsername");
            var nameInput     = document.getElementById("editUserName");
            var emailInput    = document.getElementById("editUserEmail");
            var passwordInput = document.getElementById("editUserPassword");
            var enabledInput  = document.getElementById("editUserEnabled");
            var selectedRoleId = trigger.getAttribute("data-global-role-id");

            if (usernameInput) usernameInput.value = trigger.getAttribute("data-username") || "";
            if (nameInput)     nameInput.value     = trigger.getAttribute("data-name")     || "";
            if (emailInput)    emailInput.value    = trigger.getAttribute("data-email")    || "";
            if (passwordInput) passwordInput.value = "";
            if (enabledInput)  enabledInput.checked = trigger.getAttribute("data-enabled") === "true";

            editUserModalElement.querySelectorAll('input[name="globalRoleId"]').forEach(function (radio) {
                radio.checked = radio.value === selectedRoleId;
            });
        }

        document.querySelectorAll(".js-edit-user").forEach(function (button) {
            button.addEventListener("click", function () {
                setEditUserFormState(button);
            });
        });

        var createUserModalElement = document.getElementById("createUserModal");
        if (showCreateUserModal && createUserModalElement) {
            new bootstrap.Modal(createUserModalElement).show();
        }

        if (showEditUserModal && editUserModalElement) {
            new bootstrap.Modal(editUserModalElement).show();
        }
    })();
</script>

<%@ include file="../layout/footer.jsp" %>
