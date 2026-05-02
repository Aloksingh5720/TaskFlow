<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    .meeting-table-responsive,
    .meeting-table-card-body {
        overflow: visible;
    }

    .meeting-status-dropdown .dropdown-menu {
        z-index: 1050;
    }

    .meeting-action-btn {
        width: 2rem;
        height: 2rem;
        padding: 0;
        border-radius: 999px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-width: 1px;
    }

    .meeting-action-btn i {
        font-size: 0.85rem;
    }

    .meeting-action-btn--edit {
        color: var(--md-primary);
        border-color: rgba(25, 118, 210, 0.25);
        background: rgba(25, 118, 210, 0.08);
    }

    .meeting-action-btn--edit:hover {
        color: #fff;
        background: var(--md-primary);
        border-color: var(--md-primary);
    }

    .meeting-action-btn--delete {
        color: #c62828;
        border-color: rgba(198, 40, 40, 0.22);
        background: rgba(198, 40, 40, 0.08);
    }

    .meeting-action-btn--delete:hover {
        color: #fff;
        background: #d32f2f;
        border-color: #d32f2f;
    }

    .meeting-action-btn--info {
        color: var(--md-on-surface-variant);
        border-color: rgba(68, 72, 88, 0.18);
        background: rgba(68, 72, 88, 0.08);
    }

    .meeting-action-btn--info:hover {
        color: #fff;
        background: var(--md-on-surface-variant);
        border-color: var(--md-on-surface-variant);
    }

    .meeting-join-btn {
        border: none;
        border-radius: 999px;
        padding: 0.5rem 0.95rem;
        background: linear-gradient(135deg, #34c759 0%, #4cd964 100%);
        color: #fff !important;
        font-size: 0.8rem;
        font-weight: 600;
        line-height: 1;
        text-decoration: none;
        box-shadow: 0 8px 18px rgba(52, 199, 89, 0.18);
        transition: transform var(--md-duration-short2) var(--md-motion-standard),
            box-shadow var(--md-duration-short2) var(--md-motion-standard),
            filter var(--md-duration-short2) var(--md-motion-standard);
    }

    .meeting-join-btn:hover,
    .meeting-join-btn:focus,
    .meeting-join-btn:active {
        color: #fff !important;
        background: linear-gradient(135deg, #3ecf63 0%, #5adf73 100%);
        text-decoration: none;
        box-shadow: 0 10px 20px rgba(52, 199, 89, 0.2);
        filter: none;
        transform: translateY(-1px);
    }

    .meeting-join-btn:focus-visible {
        outline: none;
        color: #fff !important;
        box-shadow: 0 0 0 0.2rem rgba(76, 217, 100, 0.18), 0 10px 20px rgba(52, 199, 89, 0.2);
    }

    .meeting-join-btn i {
        font-size: 0.9rem;
    }

    .meeting-join-empty {
        color: var(--md-on-surface-variant);
    }

    .meeting-meta-line {
        margin-top: 0.2rem;
        font-size: 0.76rem;
        color: var(--md-on-surface-variant);
    }

    .meeting-info-btn {
        width: 2rem;
        height: 2rem;
        padding: 0;
        border-radius: 999px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }

    .meeting-details-list {
        display: grid;
        gap: 1rem;
    }

    .meeting-details-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 1rem;
    }

    .meeting-details-block {
        padding: 1rem 1.1rem;
        border: 1px solid var(--md-outline-variant);
        border-radius: var(--md-shape-medium);
        background: var(--md-surface-container-low);
    }

    .meeting-details-block--hero {
        background: linear-gradient(180deg, var(--md-surface-container-lowest), var(--md-surface-container-low));
    }

    .meeting-details-block--description {
        min-height: 180px;
    }

    .meeting-details-label {
        display: block;
        margin-bottom: 0.35rem;
        font-size: 0.72rem;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: var(--md-on-surface-variant);
    }

    .meeting-details-value {
        margin: 0;
        color: var(--md-on-surface);
        white-space: pre-wrap;
        line-height: 1.55;
    }

    .meeting-details-value--strong {
        font-size: 1rem;
        font-weight: 600;
        line-height: 1.35;
    }

    .meeting-details-value--muted {
        color: var(--md-on-surface-variant);
    }

    .meeting-details-modal .modal-header {
        align-items: flex-start;
    }

    .meeting-details-modal .modal-body {
        padding-top: 1rem;
    }

    @media (max-width: 767.98px) {
        .meeting-details-grid {
            grid-template-columns: 1fr;
        }

        .meeting-details-block--description {
            min-height: 0;
        }
    }

</style>

<div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
    <div>
        <h2 class="mb-1 fw-semibold">Meetings</h2>
        <p class="mb-0 text-muted small">Meetings where you are listed as a participant.</p>
    </div>
    <div class="d-flex gap-2 flex-wrap">
        <c:if test="${canCreateMeetings}">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createMeetingModal">
                <i class="bi bi-calendar-plus me-1"></i>Schedule Meeting
            </button>
        </c:if>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0 meeting-table-card-body">
        <c:choose>
            <c:when test="${empty meetings}">
                <div class="d-flex flex-column align-items-center justify-content-center text-center text-muted py-5 px-4">
                    <div class="mb-3 opacity-25">
                        <i class="bi bi-calendar-x" style="font-size: 3.5rem;"></i>
                    </div>
                    <p class="fs-5 fw-medium mb-1 text-body">No meetings scheduled</p>
                    <p class="text-muted small mb-0">Meetings you join will appear here.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive meeting-table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4 py-3 fw-medium text-muted small text-uppercase border-bottom">Meeting</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Project</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Schedule</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Time</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Duration</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Join</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Status</th>
                                <c:if test="${showMeetingActions}">
                                    <th class="pe-4 py-3 fw-medium text-muted small text-uppercase border-bottom text-end">Actions</th>
                                </c:if>
                                <c:if test="${not showMeetingActions}">
                                    <th class="pe-4 py-3 fw-medium text-muted small text-uppercase border-bottom text-end">Details</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${meetings}" var="meeting">
                                <tr>
                                    <td class="ps-4 py-3">
                                        <div class="fw-semibold text-body">${meeting.title}</div>
                                        <div class="meeting-meta-line">Created by ${not empty meeting.creator ? meeting.creator : 'Unknown'}</div>
                                    </td>
                                    <td class="py-3 text-nowrap">
                                        <span class="text-body">${meeting.projectName}</span>
                                    </td>
                                    <td class="py-3 text-nowrap">${meeting.displayDate}</td>
                                    <td class="py-3 text-nowrap">${meeting.displayTime}</td>
                                    <td class="py-3">${meeting.duration}h</td>
                                    <td class="py-3">
                                        <c:choose>
                                            <c:when test="${not empty meeting.meetingLink}">
                                                <a href="${meeting.meetingLink}" target="_blank" rel="noopener noreferrer"
                                                    class="btn btn-sm d-inline-flex align-items-center gap-1 meeting-join-btn">
                                                    <i class="bi bi-camera-video-fill"></i>
                                                    <span>Join meeting</span>
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill text-bg-light border d-inline-flex align-items-center gap-1 px-3 py-2 meeting-join-empty">
                                                    <i class="bi bi-link-45deg"></i>
                                                    <span>No link</span>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="py-3">
                                        <c:choose>
                                            <c:when test="${canManageMeetingsByProject[meeting.projectId]}">
                                                <div class="dropdown meeting-status-dropdown">
                                                    <c:choose>
                                                        <c:when test="${meeting.meetingStatus == 'COMPLETED'}">
                                                            <c:set value="btn-success" var="currentMeetingStatusClass" />
                                                        </c:when>
                                                        <c:when test="${meeting.meetingStatus == 'IN_PROGRESS'}">
                                                            <c:set value="btn-warning" var="currentMeetingStatusClass" />
                                                        </c:when>
                                                        <c:when test="${meeting.meetingStatus == 'CANCELLED'}">
                                                            <c:set value="btn-danger" var="currentMeetingStatusClass" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:set value="btn-primary" var="currentMeetingStatusClass" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <button class="btn btn-sm ${currentMeetingStatusClass} dropdown-toggle"
                                                        type="button" aria-expanded="false" data-bs-toggle="dropdown">
                                                        ${fn:replace(meeting.meetingStatus, '_', ' ')}
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end">
                                                        <c:forEach items="${meetingStatuses}" var="status">
                                                            <c:if test="${meeting.meetingStatus != status}">
                                                                <li>
                                                                    <form action="${pageContext.request.contextPath}/meetings/${meeting.id}/status"
                                                                        method="post" class="mb-0">
                                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                                        <input type="hidden" name="meetingStatus" value="${status}" />
                                                                        <button class="dropdown-item" type="submit">
                                                                            ${fn:replace(status, '_', ' ')}
                                                                        </button>
                                                                    </form>
                                                                </li>
                                                            </c:if>
                                                        </c:forEach>
                                                    </ul>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <c:choose>
                                                    <c:when test="${meeting.meetingStatus == 'COMPLETED'}">
                                                        <span class="badge rounded-pill text-bg-success">${fn:replace(meeting.meetingStatus, '_', ' ')}</span>
                                                    </c:when>
                                                    <c:when test="${meeting.meetingStatus == 'CANCELLED'}">
                                                        <span class="badge rounded-pill text-bg-danger">${fn:replace(meeting.meetingStatus, '_', ' ')}</span>
                                                    </c:when>
                                                    <c:when test="${meeting.meetingStatus == 'IN_PROGRESS'}">
                                                        <span class="badge rounded-pill text-bg-warning">${fn:replace(meeting.meetingStatus, '_', ' ')}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge rounded-pill text-bg-primary">${fn:replace(meeting.meetingStatus, '_', ' ')}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <c:if test="${showMeetingActions}">
                                        <td class="pe-4 py-3 text-end">
                                            <div class="d-inline-flex gap-2">
                                                <button type="button"
                                                    class="btn meeting-action-btn meeting-action-btn--info meeting-info-btn"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#meetingInfoModal"
                                                    data-info-title="${fn:escapeXml(meeting.title)}"
                                                    data-info-project="${fn:escapeXml(meeting.projectName)}"
                                                    data-info-created-by="${fn:escapeXml(meeting.creator)}"
                                                    data-info-description="${fn:escapeXml(meeting.description)}"
                                                    data-info-participants="${fn:escapeXml(meeting.participantSummary)}"
                                                    title="View meeting details"
                                                    aria-label="View meeting details">
                                                    <i class="bi bi-info-circle"></i>
                                                </button>
                                                <c:if test="${canManageMeetingsByProject[meeting.projectId]}">
                                                    <button type="button"
                                                        class="btn meeting-action-btn meeting-action-btn--edit"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#editMeetingModal"
                                                        data-edit-id="${meeting.id}"
                                                        data-edit-project-id="${meeting.projectId}"
                                                        data-edit-project-name="${fn:escapeXml(meeting.projectName)}"
                                                        data-edit-title="${fn:escapeXml(meeting.title)}"
                                                        data-edit-description="${fn:escapeXml(meeting.description)}"
                                                        data-edit-link="${fn:escapeXml(meeting.meetingLink)}"
                                                        data-edit-date="${meeting.date}"
                                                        data-edit-start-time="${meeting.starTime}"
                                                        data-edit-duration="${meeting.duration}"
                                                        data-edit-status="${meeting.meetingStatus}"
                                                        data-edit-participant-ids="${meeting.participantIds}"
                                                        title="Edit meeting">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                    <button type="button"
                                                        class="btn meeting-action-btn meeting-action-btn--delete"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#deleteConfirmModal"
                                                        data-delete-action="${pageContext.request.contextPath}/meetings/${meeting.id}/delete"
                                                        data-delete-message="Permanently delete meeting '${fn:escapeXml(meeting.title)}'? This action cannot be undone."
                                                        title="Delete meeting">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </c:if>
                                    <c:if test="${not showMeetingActions}">
                                        <td class="pe-4 py-3 text-end">
                                            <button type="button"
                                                class="btn meeting-action-btn meeting-action-btn--info meeting-info-btn"
                                                data-bs-toggle="modal"
                                                data-bs-target="#meetingInfoModal"
                                                data-info-title="${fn:escapeXml(meeting.title)}"
                                                data-info-project="${fn:escapeXml(meeting.projectName)}"
                                                data-info-created-by="${fn:escapeXml(meeting.creator)}"
                                                data-info-description="${fn:escapeXml(meeting.description)}"
                                                data-info-participants="${fn:escapeXml(meeting.participantSummary)}"
                                                title="View meeting details"
                                                aria-label="View meeting details">
                                                <i class="bi bi-info-circle"></i>
                                            </button>
                                        </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<c:if test="${canCreateMeetings}">
    <%@ include file="_create-modal.jsp" %>
</c:if>
<%@ include file="_edit-modal.jsp" %>

<div class="modal fade" id="meetingInfoModal" tabindex="-1" aria-labelledby="meetingInfoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-2 meeting-details-modal">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title mb-1" id="meetingInfoModalLabel">Meeting Details</h5>
                    <p class="mb-0 text-muted small" id="meetingInfoProjectText"></p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="meeting-details-list">
                    <div class="meeting-details-grid">
                        <div class="meeting-details-block meeting-details-block--hero">
                            <span class="meeting-details-label">Created By</span>
                            <p class="meeting-details-value meeting-details-value--strong mb-0" id="meetingInfoCreatedBy"></p>
                        </div>
                        <div class="meeting-details-block meeting-details-block--hero">
                            <span class="meeting-details-label">Participants</span>
                            <p class="meeting-details-value meeting-details-value--muted mb-0" id="meetingInfoParticipants"></p>
                        </div>
                    </div>
                    <div class="meeting-details-block meeting-details-block--description">
                        <span class="meeting-details-label">Description</span>
                        <p class="meeting-details-value mb-0" id="meetingInfoDescription"></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    (function () {
        var infoModal = document.getElementById('meetingInfoModal');
        if (!infoModal) return;

        infoModal.addEventListener('show.bs.modal', function (event) {
            var trigger = event.relatedTarget;
            if (!trigger) return;

            var title = trigger.getAttribute('data-info-title') || 'Meeting Details';
            var project = trigger.getAttribute('data-info-project') || '';
            var createdBy = trigger.getAttribute('data-info-created-by') || 'Unknown';
            var description = trigger.getAttribute('data-info-description') || 'No description added.';
            var participants = trigger.getAttribute('data-info-participants') || 'No participants';

            var titleNode = infoModal.querySelector('#meetingInfoModalLabel');
            if (titleNode) titleNode.textContent = title;

            var projectNode = infoModal.querySelector('#meetingInfoProjectText');
            if (projectNode) projectNode.textContent = project;

            var createdByNode = infoModal.querySelector('#meetingInfoCreatedBy');
            if (createdByNode) createdByNode.textContent = createdBy;

            var participantsNode = infoModal.querySelector('#meetingInfoParticipants');
            if (participantsNode) participantsNode.textContent = participants;

            var descriptionNode = infoModal.querySelector('#meetingInfoDescription');
            if (descriptionNode) descriptionNode.textContent = description;
        });
    })();
</script>

<%@ include file="../layout/footer.jsp" %>
