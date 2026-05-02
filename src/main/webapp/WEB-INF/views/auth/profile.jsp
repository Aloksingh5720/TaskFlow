<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="section-card mb-4"
    style="background:linear-gradient(135deg,var(--md-surface-container-lowest),var(--md-primary-container));border-color:rgba(0,0,0,0.04);">
    <div class="d-flex align-items-start justify-content-between flex-wrap gap-3">
        <div class="d-flex align-items-center gap-3">
            <div class="avatar avatar-xl avatar-primary shadow-surface">
                ${user.username.substring(0,1).toUpperCase()}
            </div>
            <div>
                <div class="text-label-sm">Account Profile</div>
                <h2 class="mb-1">${user.name}</h2>
                <div class="d-flex align-items-center flex-wrap gap-2">
                    <span class="text-muted">${user.email}</span>
                </div>
            </div>
        </div>
        <div class="d-flex flex-wrap gap-2">
            <c:choose>
                <c:when test="${user.globalRole == 'SUPER_ADMIN'}">
                    <span class="chip chip-error">${fn:replace(user.globalRole, '_', ' ')}</span>
                </c:when>
                <c:when test="${user.globalRole == 'ADMIN'}">
                    <span class="chip chip-warning">${fn:replace(user.globalRole, '_', ' ')}</span>
                </c:when>
                <c:otherwise>
                    <span class="chip chip-secondary">${fn:replace(user.globalRole, '_', ' ')}</span>
                </c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${user.enabled}">
                    <span class="chip chip-success">Enabled</span>
                </c:when>
                <c:otherwise>
                    <span class="chip chip-error">Disabled</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="section-card h-100">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4">
                <div>
                    <h5 class="mb-1">Account Information</h5>
                    <p class="text-muted mb-0">Standard identity and access details for your account.</p>
                </div>
            </div>

            <div style="border:1px solid var(--md-outline-variant);border-radius:20px;overflow:hidden;">
                <div class="d-flex justify-content-between align-items-center px-4 py-3"
                    style="background:var(--md-surface-container-low);border-bottom:1px solid var(--md-outline-variant);">
                    <span class="fw-semibold">Profile Details</span>
                </div>
                <div class="px-4 py-1">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-3"
                        style="border-bottom:1px solid var(--md-outline-variant);">
                        <span class="text-muted">Full name</span>
                        <span class="fw-medium">${user.name}</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-3"
                        style="border-bottom:1px solid var(--md-outline-variant);">
                        <span class="text-muted">Email address</span>
                        <span class="fw-medium">${user.email}</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-3"
                        style="border-bottom:1px solid var(--md-outline-variant);">
                        <span class="text-muted">Username</span>
                        <span class="fw-medium">@${user.username}</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-3"
                        style="border-bottom:1px solid var(--md-outline-variant);">
                        <span class="text-muted">Global role</span>
                        <span class="fw-medium">${fn:replace(user.globalRole, '_', ' ')}</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-3">
                        <span class="text-muted">Account status</span>
                        <span class="fw-medium">${user.enabled ? 'Enabled' : 'Disabled'}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <div class="section-card mb-4">
            <h6 class="mb-3">Quick Access</h6>
            <div class="d-grid gap-2">
                <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                    <i class="bi bi-speedometer2 me-1"></i>Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/projects" class="btn btn-secondary">
                    <i class="bi bi-folder2-open me-1"></i>Projects
                </a>
            </div>
        </div>

        <div class="section-card">
            <h6 class="mb-3">Security</h6>
            <div class="d-flex align-items-start gap-3">
                <div class="card-icon card-icon-md card-icon-secondary">
                    <i class="bi bi-shield-check"></i>
                </div>
                <div>
                    <div class="fw-semibold mb-1">Authenticated Account</div>
                    <div class="text-muted small">This page reflects the currently signed-in user identity.</div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
