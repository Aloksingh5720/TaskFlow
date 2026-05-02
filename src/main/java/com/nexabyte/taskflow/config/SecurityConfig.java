package com.nexabyte.taskflow.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import jakarta.servlet.DispatcherType;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

        @Bean
        protected SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

                // http.csrf(csrf -> csrf.disable());

                http.authorizeHttpRequests(auth -> auth
                                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                                .requestMatchers("/login").permitAll()
                                .requestMatchers("/static/**", "/css/**", "/js/**", "/fonts/**", "/images/**",
                                                "/webjars/**")
                                .permitAll()
                                .requestMatchers("/admin/**").hasAnyRole("ADMIN", "SUPER_ADMIN")
                                .anyRequest().authenticated());

                http.sessionManagement(session -> session
                                .sessionFixation().migrateSession());

                http.formLogin(form -> form
                                .loginPage("/login")
                                .defaultSuccessUrl("/dashboard", true)
                                .permitAll());

                http.logout(logout -> logout
                                .logoutSuccessUrl("/login?logout=true")
                                .invalidateHttpSession(true)
                                .deleteCookies("JSESSIONID")
                                .permitAll());

                http.exceptionHandling(ex -> ex
                                .accessDeniedPage("/error/403"));

                http.headers(headers -> headers
                                .frameOptions(frameOptions -> frameOptions.sameOrigin()));

                return http.build();
        }

        @Bean
        public PasswordEncoder passwordEncoder() {
                return PasswordEncoderFactories.createDelegatingPasswordEncoder();
        }

        @Bean
        public AuthenticationManager authenticationManager(
                        AuthenticationConfiguration authConfig) throws Exception {
                return authConfig.getAuthenticationManager();
        }
}
