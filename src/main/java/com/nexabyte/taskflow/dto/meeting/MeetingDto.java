package com.nexabyte.taskflow.dto.meeting;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.StringJoiner;

import com.nexabyte.taskflow.constants.MeetingStatus;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingDto {

    private static final DateTimeFormatter DISPLAY_DATE_FORMATTER = DateTimeFormatter.ofPattern("dd MMM yyyy");
    private static final DateTimeFormatter DISPLAY_TIME_FORMATTER = DateTimeFormatter.ofPattern("hh:mm a");

    private Long id;

    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must not exceed 255 characters")
    private String title;

    private String description;

    @Size(max = 1000, message = "Meeting link must not exceed 1000 characters")
    private String meetingLink;

    @NotNull(message = "Meeting date is required")
    private LocalDate date;

    @NotNull(message = "Start time is required")
    private LocalTime starTime;

    @NotNull(message = "Duration is required")
    @DecimalMin(value = "0.25", message = "Duration must be at least 0.25 hours")
    private BigDecimal duration;

    private MeetingStatus meetingStatus;

    @NotNull(message = "Project is required")
    private Long projectId;

    private String projectName;

    private Long createdBy;

    private String creator;

    private List<Long> participantIds;

    private List<String> participantNames;

    public String getDisplayDate() {
        return date != null ? date.format(DISPLAY_DATE_FORMATTER) : "";
    }

    public String getDisplayTime() {
        return starTime != null ? starTime.format(DISPLAY_TIME_FORMATTER) : "";
    }

    public String getParticipantSummary() {
        if (participantNames == null || participantNames.isEmpty()) {
            return "";
        }

        StringJoiner joiner = new StringJoiner(", ");
        participantNames.forEach(joiner::add);
        return joiner.toString();
    }
}
