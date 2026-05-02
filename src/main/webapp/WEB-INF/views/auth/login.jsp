<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sign In &mdash; TaskFlow</title>
    <link
      href="${pageContext.request.contextPath}/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/css/bootstrap-icons.min.css"
    />
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/css/theme.css"
    />
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/css/app.css"
    />
  </head>

  <body class="app-body">
    <div class="auth-shell">
      <div class="auth-card">
        <!-- logo -->
        <div class="auth-logo">
          <i class="bi bi-grid-1x2-fill"></i>
        </div>
        <h1 class="auth-title">Welcome back</h1>
        <p class="auth-subtitle">Sign in to your TaskFlow workspace</p>

        <c:if test="${param.error != null}">
          <div class="alert alert-danger mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>Invalid username or password. Please try again.</span>
          </div>
        </c:if>
        <c:if test="${param.logout != null}">
          <div class="alert alert-success mb-4" role="alert">
            <i class="bi bi-check-circle-fill"></i>
            <span>You have been signed out successfully.</span>
          </div>
        </c:if>

        <!-- username and password form -->
        <form
          method="post"
          action="${pageContext.request.contextPath}/login"
        >
          <input
            type="hidden"
            name="${_csrf.parameterName}"
            value="${_csrf.token}"
          />

          <div class="mb-4">
            <label for="username" class="form-label">Username</label>
            <div class="input-group">
              <span class="input-group-text bg-body-tertiary border-end-0">
                <i class="bi bi-person text-secondary"></i>
              </span>
              <input
                type="text"
                class="form-control border-start-0"
                id="username"
                name="username"
                placeholder="Enter your username"
                required
                autofocus
              />
            </div>
          </div>

          <div class="mb-4">
            <label for="password" class="form-label">Password</label>
            <div class="input-group">
              <span class="input-group-text bg-body-tertiary border-end-0">
                <i class="bi bi-lock text-secondary"></i>
              </span>
              <input
                type="password"
                class="form-control border-start-0"
                id="password"
                name="password"
                placeholder="Enter your password"
                required
              />
            </div>
          </div>

          <button type="submit" class="btn btn-primary w-100 py-3 fs-6">
            <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
          </button>
        </form>
      </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/app.js"></script>
  </body>
</html>
