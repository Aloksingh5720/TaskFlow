package com.nexabyte.taskflow.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.mapper.UserMapper;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
// CHECKED
public class AuthController {

    @GetMapping("/login")
    public String login() {
        return "auth/login";
    }

    @GetMapping("/profile")
    public String showUserProfile(@AuthenticationPrincipal User user, Model model) {
        model.addAttribute("user", UserMapper.toDto(user));
        return "auth/profile";
    }
}
