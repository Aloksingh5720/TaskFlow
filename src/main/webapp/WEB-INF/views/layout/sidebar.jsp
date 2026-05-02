<%@taglib prefix="sec" uri="http://www.springframework.org/security/tags" %> <%@
taglib prefix="c" uri="jakarta.tags.core" %> <%@ taglib prefix="fn"
uri="jakarta.tags.functions" %>

<c:set value="${pageContext.request.contextPath}" var="sidebarContextPath" />
<c:set value="${pageContext.request.requestURI}" var="sidebarCurrentUri" />
<c:set
  value="${fn:replace(sidebarCurrentUri, sidebarContextPath, '')}"
  var="sidebarRelativeUri"
/>
<c:set
  value="${sidebarRelativeUri eq '/work-packages' and param.assignee eq 'me'}"
  var="sidebarAssignedWorkActive"
/>
<c:set
  value="${sidebarRelativeUri eq '/meetings'}"
  var="sidebarMeetingsActive"
/>
<c:set value="${sidebarRelativeUri eq '/issues'}" var="sidebarIssuesActive" />
<c:set
  value="${sidebarRelativeUri eq '/work-packages' and empty param.assignee and empty param.overdue}"
  var="sidebarAllPackagesActive"
/>
<c:set value="${fn:split(sidebarRelativeUri, '/')}" var="sidebarUriParts" />
<c:set value="" var="sidebarProjectId" />

<c:choose>
  <c:when test="${not empty project and not empty project.id}">
    <c:set value="${project.id}" var="sidebarProjectId" />
  </c:when>
  <c:when test="${not empty projectId}">
    <c:set value="${projectId}" var="sidebarProjectId" />
  </c:when>
  <c:when test="${not empty workPackage and not empty workPackage.projectId}">
    <c:set value="${workPackage.projectId}" var="sidebarProjectId" />
  </c:when>
  <c:when test="${not empty param.projectId}">
    <c:set value="${param.projectId}" var="sidebarProjectId" />
  </c:when>
  <c:when
    test="${fn:length(sidebarUriParts) gt 2 and sidebarUriParts[1] == 'projects' and sidebarUriParts[2] != 'new'}"
  >
    <c:set value="${sidebarUriParts[2]}" var="sidebarProjectId" />
  </c:when>
  <c:when
    test="${fn:length(sidebarUriParts) gt 3 and sidebarUriParts[1] == 'work-packages' and sidebarUriParts[2] == 'project'}"
  >
    <c:set value="${sidebarUriParts[3]}" var="sidebarProjectId" />
  </c:when>
</c:choose>

<ul class="sidebar-nav">
  <li class="nav-item">
    <a
      class="nav-link ${sidebarRelativeUri == '/dashboard' ? 'active' : ''}"
      href="${pageContext.request.contextPath}/dashboard"
    >
      <i class="bi bi-speedometer2"></i>
      <span>Dashboard</span>
    </a>
  </li>
  <li class="nav-item">
    <a
      class="nav-link ${fn:startsWith(sidebarRelativeUri, '/projects') ? 'active' : ''}"
      href="${pageContext.request.contextPath}/projects"
    >
      <i class="bi bi-folder2-open"></i>
      <span>Projects</span>
    </a>
  </li>
  <li class="nav-item">
    <a
      class="nav-link ${sidebarAssignedWorkActive ? 'active' : ''}"
      href="${pageContext.request.contextPath}/work-packages?assignee=me"
    >
      <i class="bi bi-person-workspace"></i>
      <span>My Tasks</span>
    </a>
  </li>
  <c:if test="${showMeetings}">
    <li class="nav-item">
      <a
        class="nav-link ${sidebarMeetingsActive ? 'active' : ''}"
        href="${pageContext.request.contextPath}/meetings"
      >
        <i class="bi bi-calendar-event"></i>
        <span>Meetings</span>
      </a>
    </li>
  </c:if>
  <c:if test="${showCalendar}">
    <li class="nav-item">
      <a
        class="nav-link ${fn:startsWith(sidebarRelativeUri, '/calendar') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/calendar"
      >
        <i class="bi bi-calendar3"></i>
        <span>Calendar</span>
      </a>
    </li>
  </c:if>
  <li class="nav-item">
    <a
      class="nav-link ${sidebarIssuesActive ? 'active' : ''}"
      href="${pageContext.request.contextPath}/issues"
    >
      <i class="bi bi-exclamation-diamond"></i>
      <span>Issues</span>
    </a>
  </li>

  <c:if test="${not empty sidebarProjectId}">
    <li class="nav-item mt-2">
      <div
        class="mb-1 px-3 sidebar-label"
        style="
          font-size: 0.7rem;
          font-weight: 700;
          letter-spacing: 0.1em;
          text-transform: uppercase;
          color: var(--md-on-surface-variant);
          opacity: 0.6;
        "
      >
        Project
      </div>
    </li>
    <li class="nav-item">
      <a
        class="nav-link ${fn:contains(sidebarRelativeUri, '/work-packages/project/') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/work-packages/project/${sidebarProjectId}"
      >
        <i class="bi bi-list-check"></i>
        <span>Work Packages</span>
      </a>
    </li>
    <li class="nav-item">
      <a
        class="nav-link ${fn:contains(sidebarRelativeUri, '/kanban') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/projects/${sidebarProjectId}/kanban"
      >
        <i class="bi bi-columns-gap"></i>
        <span>Trace Board</span>
      </a>
    </li>
    <li class="nav-item">
      <a
        class="nav-link ${fn:contains(sidebarRelativeUri, '/gantt') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/projects/${sidebarProjectId}/gantt"
      >
        <i class="bi bi-calendar3-range"></i>
        <span>Gantt Chart</span>
      </a>
    </li>
    <li class="nav-item">
      <a
        class="nav-link ${fn:contains(sidebarRelativeUri, '/members') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/projects/${sidebarProjectId}/members"
      >
        <i class="bi bi-people"></i>
        <span>Members</span>
      </a>
    </li>
    <li class="nav-item">
      <a
        class="nav-link ${fn:contains(sidebarRelativeUri, '/settings') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/projects/${sidebarProjectId}/settings"
      >
        <i class="bi bi-gear"></i>
        <span>Settings</span>
      </a>
    </li>
  </c:if>

  <sec:authorize access="hasAnyAuthority('ROLE_ADMIN', 'ROLE_SUPER_ADMIN')">
    <li class="nav-item mt-2">
      <div
        class="mb-1 px-3 sidebar-label"
        style="
          font-size: 0.7rem;
          font-weight: 700;
          letter-spacing: 0.1em;
          text-transform: uppercase;
          color: var(--md-on-surface-variant);
          opacity: 0.6;
        "
      >
        Administration
      </div>
    </li>
    <c:if test="${showAdminOption}">
      <li class="nav-item">
        <a
          class="nav-link ${sidebarAllPackagesActive ? 'active' : ''}"
          href="${pageContext.request.contextPath}/work-packages"
        >
          <i class="bi bi-list-check"></i>
          <span>All Packages</span>
        </a>
      </li>
    </c:if>
    <li class="nav-item">
      <a
        class="nav-link ${fn:contains(sidebarRelativeUri, '/admin/users') ? 'active' : ''}"
        href="${pageContext.request.contextPath}/admin/users"
      >
        <i class="bi bi-people"></i>
        <span>Users</span>
      </a>
    </li>
  </sec:authorize>
</ul>
