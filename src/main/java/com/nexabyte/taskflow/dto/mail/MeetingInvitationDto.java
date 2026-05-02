package com.nexabyte.taskflow.dto.mail;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingInvitationDto {
    private String name;
    private String title;
    private String date;
    private String time;
    private String duration;
    private String link;
}
