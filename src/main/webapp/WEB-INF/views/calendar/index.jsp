<%@ include file="../layout/header.jsp" %> <%@ taglib prefix="c"
uri="jakarta.tags.core" %> <%@ taglib prefix="fn" uri="jakarta.tags.functions"
%>

<div
  class="align-items-center d-flex flex-wrap gap-3 justify-content-between mb-4 page-header"
>
  <div>
    <h2 class="mb-1">Calendar</h2>
    <p class="mb-0 text-muted">
      Track meetings and work packages across your projects.
    </p>
  </div>
</div>

<div class="section-card calendar-shell">
  <div class="calendar-legend">
    <div class="calendar-legend-item">
      <div class="calendar-legend-color calendar-legend-color--meeting"></div>
      <span>Meeting</span>
    </div>
    <div class="calendar-legend-item">
      <div
        class="calendar-legend-color calendar-legend-color--workpackage"
      ></div>
      <span>Work Package</span>
    </div>
  </div>
  <div class="calendar-shell__body">
    <div id="calendar"></div>
  </div>
</div>

<style>
  :root {
    --calendar-header-bg: var(--md-surface-container-low);
    --calendar-border-color: var(--md-outline-variant);
    --calendar-today-bg: #edf4ff;
    --calendar-weekend-bg: #f6f8fd;
    --calendar-event-meeting-bg: #f59e0b;
    --calendar-event-workpackage-bg: #10b981;
    --calendar-event-text: var(--md-on-primary);
  }

  .calendar-shell {
    overflow: hidden;
    padding: 0;
  }

  .calendar-shell__body {
    padding: 0 1.25rem 1.25rem;
  }

  #calendar {
    min-height: 500px;
    font-family: "Roboto", system-ui, sans-serif;
    position: relative;
  }

  #calendar.is-loading::after {
    content: "Loading calendar events...";
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(250, 251, 255, 0.92);
    color: var(--md-on-surface-variant);
    font-size: 1rem;
    font-weight: 500;
    z-index: 10;
  }

  .fc-header-toolbar {
    padding: 1rem 0 1rem;
    margin: 0;
    gap: 1rem;
  }

  .fc-header-toolbar h2 {
    font-size: 1.25rem;
    font-weight: 500;
    margin: 0;
    color: var(--md-on-surface);
  }

  .fc-button-primary {
    background: var(--md-surface-container-lowest) !important;
    border: 1px solid var(--md-outline-variant) !important;
    color: var(--md-on-surface) !important;
    padding: 0.45rem 0.85rem !important;
    border-radius: var(--app-radius-sm) !important;
    box-shadow: none !important;
    transition:
      background-color var(--md-duration-short4) var(--md-motion-standard),
      border-color var(--md-duration-short4) var(--md-motion-standard),
      color var(--md-duration-short4) var(--md-motion-standard);
    text-transform: capitalize;
  }

  .fc-button-primary:hover {
    background: var(--md-surface-container-low) !important;
    border-color: var(--md-outline) !important;
    color: var(--md-primary) !important;
  }

  .fc-button-primary:not(:disabled).fc-button-active,
  .fc-button-primary:not(:disabled):active {
    background: var(--md-primary-container) !important;
    border-color: var(--md-primary) !important;
    color: var(--md-primary) !important;
  }

  .fc-button-primary:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .fc-theme-standard .fc-scrollgrid {
    border: 1px solid var(--calendar-border-color);
    border-radius: var(--app-radius);
    overflow: hidden;
    background: var(--md-surface-container-lowest);
    box-shadow: var(--md-shadow-1);
  }

  .fc-theme-standard td,
  .fc-theme-standard th {
    border-color: var(--calendar-border-color);
  }

  .fc-col-header-cell {
    background: var(--calendar-header-bg);
    padding: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
    font-size: 0.75rem;
    letter-spacing: 0.05em;
    color: var(--md-on-surface-variant);
  }

  .fc-daygrid-day {
    min-height: 100px;
    transition: background-color var(--md-duration-short4)
      var(--md-motion-standard);
    background: var(--md-surface-container-lowest);
  }

  .fc-daygrid-day:hover {
    background-color: var(--md-surface-container-low);
  }

  .fc-day-today {
    background-color: var(--calendar-today-bg) !important;
  }

  .fc-daygrid-day-number {
    padding: 0.5rem;
    font-weight: 500;
    color: var(--md-on-surface);
  }

  .fc-day-sat,
  .fc-day-sun {
    background-color: var(--calendar-weekend-bg);
  }

  .fc-event {
    border: none !important;
    border-radius: var(--md-shape-small);
    padding: 0.25rem 0.45rem;
    margin: 0.125rem;
    font-size: 0.78rem;
    font-weight: 500;
    cursor: pointer;
    transition:
      transform var(--md-duration-short4) var(--md-motion-standard),
      box-shadow var(--md-duration-short4) var(--md-motion-standard);
    box-shadow: none;
    color: var(--calendar-event-text);
  }

  .fc-event:hover {
    transform: translateY(-1px);
    box-shadow: var(--md-shadow-1);
  }

  .fc-event-meeting {
    background-color: var(--calendar-event-meeting-bg);
  }

  .fc-event-work_package {
    background-color: var(--calendar-event-workpackage-bg);
  }

  .fc-list-event:hover td,
  .fc-list-day:hover td {
    background: var(--md-surface-container-low);
  }

  .fc-list-day-cushion,
  .fc-list-table td,
  .fc-list-table th {
    background: var(--md-surface-container-lowest);
    color: var(--md-on-surface);
    border-color: var(--calendar-border-color);
  }

  .fc-event-title {
    font-weight: 600;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .fc-popover {
    border: 1px solid var(--calendar-border-color);
    border-radius: var(--app-radius);
    box-shadow: var(--md-shadow-2);
    overflow: hidden;
  }

  .fc-popover-header {
    background: var(--md-surface-container-low);
    color: var(--md-on-surface);
    padding: 0.75rem 1rem;
  }

  .fc-popover-title {
    margin: 0;
    font-size: 0.9rem;
    font-weight: 600;
  }

  .fc-popover-close {
    color: var(--md-on-surface-variant);
    opacity: 0.8;
  }

  .fc-popover-close:hover {
    opacity: 1;
  }

  .fc-popover-body {
    padding: 1rem;
    background: var(--md-surface-container-lowest);
  }

  #eventDetailModal .modal-content {
    border: 1px solid var(--calendar-border-color);
    border-radius: var(--app-radius-lg);
    overflow: hidden;
    box-shadow: var(--md-shadow-3);
    background-clip: padding-box;
    background-color: var(--md-surface-container-lowest);
  }

  #eventDetailModal .modal-header {
    background: var(--md-surface-container-low);
    color: var(--md-on-surface);
    border-bottom: 1px solid var(--calendar-border-color);
    padding: 1rem 1.25rem;
    border-top-left-radius: inherit;
    border-top-right-radius: inherit;
  }

  #eventDetailModal .modal-title {
    color: var(--md-on-surface);
  }

  #eventDetailModal .btn-close-white {
    filter: none;
    opacity: 0.6;
  }

  #eventDetailModal .btn-close-white:hover {
    opacity: 1;
  }

  #eventDetailModal .modal-body,
  #eventDetailModal .modal-footer {
    background: var(--md-surface-container-lowest);
  }

  #eventDetailModal .modal-body {
    border-radius: 0;
  }

  #eventDetailModal .modal-footer {
    border-top: 1px solid var(--calendar-border-color);
    padding: 0.9rem 1.25rem 1.1rem;
    border-bottom-left-radius: inherit;
    border-bottom-right-radius: inherit;
  }

  #eventDetailModal .btn {
    border-radius: var(--app-radius-sm);
  }

  .calendar-legend {
    display: flex;
    gap: 1.5rem;
    padding: 1rem 1.25rem;
    background: var(--md-surface-container-low);
    border-bottom: 1px solid var(--calendar-border-color);
  }

  .calendar-legend-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.85rem;
    color: var(--md-on-surface-variant);
  }

  .calendar-legend-color {
    width: 12px;
    height: 12px;
    border-radius: 999px;
    box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.18);
  }

  .calendar-legend-color--meeting {
    background-color: var(--calendar-event-meeting-bg);
  }

  .calendar-legend-color--workpackage {
    background-color: var(--calendar-event-workpackage-bg);
  }

  @media (max-width: 768px) {
    .calendar-shell__body {
      padding: 0 0.75rem 0.75rem;
    }

    .fc-header-toolbar {
      flex-direction: column;
      gap: 0.75rem;
      align-items: stretch;
    }

    .fc-header-toolbar .fc-toolbar-start {
      order: 2;
    }

    .fc-header-toolbar .fc-toolbar-end {
      order: 3;
    }

    .calendar-legend {
      flex-wrap: wrap;
      gap: 0.75rem;
      padding: 0.85rem 0.9rem;
    }
  }
</style>

<script src="${pageContext.request.contextPath}/js/fullcalendar.global.min.js"></script>
<script>
  (function () {
    "use strict";

    let calendar = null;
    const contextPath = "${pageContext.request.contextPath}";

    document.addEventListener("DOMContentLoaded", function () {
      const calendarEl = document.getElementById("calendar");

      // Initialize FullCalendar
      calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: "dayGridMonth",
        customButtons: {
          goToToday: {
            text: "today",
            click: function () {
              calendar.today();
            },
          },
        },
        headerToolbar: {
          left: "prev,next goToToday",
          center: "title",
          right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth",
        },
        events: {
          url: contextPath + "/calendar/events",
          failure: function () {
            console.error("Failed to load calendar events");
          },
          eventDataTransform: function (eventData) {
            const start = normalizeCalendarDateValue(
              eventData.startDateTime || eventData.startDate,
            );
            const end = normalizeCalendarDateValue(
              eventData.endDateTime || eventData.endDate,
            );
            const displayColor = getEventDisplayColor(eventData);

            const transformed = {
              id: eventData.id,
              title: eventData.title,
              start: start,
              end: end,
              allDay: eventData.allDay === true || eventData.allDay === "true",
              extendedProps: {
                eventType: eventData.eventType,
                description: eventData.description,
                projectName: eventData.projectName,
                projectId: eventData.projectId,
                status: eventData.status,
                priority: eventData.priority,
                assigneeName: eventData.assigneeName,
                url: eventData.url,
                startTime: eventData.startTime,
                endTime: eventData.endTime,
              },
              backgroundColor: displayColor,
              borderColor: displayColor,
              textColor: "#ffffff",
            };
            return transformed;
          },
        },
        eventClassNames: function (arg) {
          const event = arg.event;
          const classes = [];

          if (event.extendedProps.eventType === "MEETING") {
            classes.push("fc-event-meeting");
          } else if (event.extendedProps.eventType === "WORK_PACKAGE") {
            classes.push("fc-event-work_package");
          }

          return classes;
        },
        eventContent: function (arg) {
          const event = arg.event;
          const props = event.extendedProps;

          let timeHtml = "";
          if (!event.allDay && props.startTime) {
            const time = props.startTime.substring(0, 5);
            timeHtml =
              '<div class="fc-event-time" style="font-size: 0.7em; opacity: 0.9;">' +
              time +
              "</div>";
          }

          return {
            html:
              '<div class="fc-event-main-wrapper">' +
              timeHtml +
              '<div class="fc-event-title">' +
              event.title +
              "</div></div>",
          };
        },
        eventClick: function (info) {
          const event = info.event;
          const props = event.extendedProps;

          const eventTypeIcon =
            props.eventType === "MEETING"
              ? "bi-calendar-event"
              : "bi-list-check";
          const eventTypeLabel =
            props.eventType === "MEETING" ? "Meeting" : "Work Package";
          const projectHtml = props.projectName
            ? '<div class="mb-3"><span class="text-muted"><i class="bi bi-folder me-1"></i>Project:</span><span class="ms-2">' +
              props.projectName +
              "</span></div>"
            : "";
          const descriptionHtml = props.description
            ? '<div class="mb-3"><span class="text-muted"><i class="bi bi-card-text me-1"></i>Description:</span><p class="mt-1 mb-0 text-muted">' +
              props.description +
              "</p></div>"
            : "";
          const timeHtml =
            !event.allDay && props.startTime
              ? '<div class="mb-3"><span class="text-muted"><i class="bi bi-clock me-1"></i>Time:</span><span class="ms-2">' +
                props.startTime.substring(0, 5) +
                " - " +
                (props.endTime ? props.endTime.substring(0, 5) : "N/A") +
                "</span></div>"
              : "";
          const assigneeLabel =
            props.eventType === "MEETING" ? "Participants" : "Assignee";
          const assigneeHtml = props.assigneeName
            ? '<div class="mb-3"><span class="text-muted"><i class="bi bi-person me-1"></i>' +
              assigneeLabel +
              ':</span><span class="ms-2">' +
              props.assigneeName +
              "</span></div>"
            : "";
          const statusHtml = props.status
            ? '<div class="mb-3"><span class="text-muted"><i class="bi bi-flag me-1"></i>Status:</span><span class="ms-2 badge bg-' +
              getStatusBadgeColor(props.status) +
              '">' +
              props.status +
              "</span></div>"
            : "";
          const priorityHtml = props.priority
            ? '<div class="mb-3"><span class="text-muted"><i class="bi bi-exclamation-triangle me-1"></i>Priority:</span><span class="ms-2 badge bg-' +
              getPriorityBadgeColor(props.priority) +
              '">' +
              props.priority +
              "</span></div>"
            : "";
          const actionHtml = props.url
            ? '<a href="' +
              contextPath +
              props.url +
              '" class="btn btn-primary"><i class="bi bi-box-arrow-up-right me-1"></i>View Details</a>'
            : "";

          const modalHtml =
            '<div class="modal fade" id="eventDetailModal" tabindex="-1" aria-labelledby="eventDetailModalLabel" aria-hidden="true">' +
            '<div class="modal-dialog modal-dialog-centered">' +
            '<div class="modal-content">' +
            '<div class="modal-header">' +
            '<h5 class="modal-title" id="eventDetailModalLabel">' +
            '<i class="bi ' +
            eventTypeIcon +
            ' me-2"></i>' +
            eventTypeLabel +
            "</h5>" +
            '<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>' +
            "</div>" +
            '<div class="modal-body">' +
            '<h6 class="fw-bold mb-3">' +
            event.title +
            "</h6>" +
            projectHtml +
            descriptionHtml +
            '<div class="mb-3"><span class="text-muted"><i class="bi bi-calendar3 me-1"></i>Date:</span><span class="ms-2">' +
            event.start.toLocaleDateString("en-GB", {
              day: "numeric",
              month: "short",
              year: "numeric",
            }) +
            "</span></div>" +
            timeHtml +
            assigneeHtml +
            statusHtml +
            priorityHtml +
            "</div>" +
            '<div class="modal-footer">' +
            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>' +
            actionHtml +
            "</div>" +
            "</div>" +
            "</div>" +
            "</div>";

          // Remove existing modal if any
          const existingModal = document.getElementById("eventDetailModal");
          if (existingModal) {
            existingModal.remove();
          }

          document.body.insertAdjacentHTML("beforeend", modalHtml);

          const modal = new bootstrap.Modal(
            document.getElementById("eventDetailModal"),
          );
          modal.show();
        },
        eventDidMount: function (info) {
          // Add tooltip with basic info
          const props = info.event.extendedProps;
          let tooltipText = info.event.title;

          if (props.projectName) {
            tooltipText += " - " + props.projectName;
          }

          info.el.setAttribute("title", tooltipText);
        },
        firstDay: 1,
        height: "auto",
        fixedWeekCount: false,
        showNonCurrentDates: true,
        dayMaxEventRows: 3,
        eventLimitText: function (n) {
          return "+" + n + " more";
        },
        loading: function (isLoading) {
          calendarEl.classList.toggle("is-loading", isLoading);
        },
      });

      calendar.render();

      // Helper functions for badge colors
      function getStatusBadgeColor(status) {
        const statusColors = {
          COMPLETED: "success",
          IN_PROGRESS: "primary",
          PENDING: "warning",
          SCHEDULED: "info",
          OVERDUE: "danger",
          CANCELLED: "secondary",
        };
        return statusColors[status] || "secondary";
      }

      function getPriorityBadgeColor(priority) {
        const priorityColors = {
          HIGH: "danger",
          MEDIUM: "warning",
          LOW: "success",
          CRITICAL: "danger",
        };
        return priorityColors[priority] || "secondary";
      }

      function getEventDisplayColor(eventData) {
        if (eventData.eventType === "MEETING") {
          return (
            getCssVariableValue("--calendar-event-meeting-bg") || "#f59e0b"
          );
        }

        return (
          getCssVariableValue("--calendar-event-workpackage-bg") || "#10b981"
        );
      }

      function getCssVariableValue(name) {
        return getComputedStyle(document.documentElement)
          .getPropertyValue(name)
          .trim();
      }

      function normalizeCalendarDateValue(value) {
        if (!value) {
          return null;
        }

        if (Array.isArray(value)) {
          const year = value[0];
          const month = String(value[1]).padStart(2, "0");
          const day = String(value[2]).padStart(2, "0");

          if (value.length >= 5) {
            const hour = String(value[3]).padStart(2, "0");
            const minute = String(value[4]).padStart(2, "0");
            const second = String(value[5] || 0).padStart(2, "0");
            return (
              year +
              "-" +
              month +
              "-" +
              day +
              "T" +
              hour +
              ":" +
              minute +
              ":" +
              second
            );
          }

          return year + "-" + month + "-" + day;
        }

        return value;
      }
    });
  })();
</script>

<%@ include file="../layout/footer.jsp" %>
