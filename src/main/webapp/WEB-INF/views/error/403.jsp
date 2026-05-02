<%@ include file="../layout/header.jsp" %>

    <div class="error-center">
        <div class="error-code">403</div>
        <div class="kpi-icon warning mx-auto mb-3"
            style="width:64px;height:64px;font-size:2rem;border-radius:var(--md-shape-large)">
            <i class="bi bi-shield-exclamation"></i>
        </div>
        <h2 style="font-weight:400">Access Denied</h2>
        <p style="color:var(--md-on-surface-variant);max-width:400px;text-align:center;margin:0 auto 24px">
            You do not have permission to view this resource. Please contact your administrator if you believe this is
            an error.
        </p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
            <i class="bi bi-house me-2"></i>Go to Dashboard
        </a>
    </div>

    <%@ include file="../layout/footer.jsp" %>