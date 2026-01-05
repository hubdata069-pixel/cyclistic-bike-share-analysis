# =========================================================
# Cyclistic Bike Share Analysis
# Full Visualization Script (p1 – p8)
# Updated: Thinner bars (p7), vertical points (p8)
# =========================================================

# -------------------------------
# Load libraries
# -------------------------------
library(tidyverse)
library(lubridate)

# -------------------------------
# Create visuals directory
# -------------------------------
dir.create("~/Desktop/Cyclistic-Analysis/visuals", showWarnings = FALSE)

# -------------------------------
# Load the data
# -------------------------------
cyclistic_all <- read_csv(
  "/Users/muju/Desktop/Cyclistic-Analysis/data/cyclistic_all.csv"
)

# -------------------------------
# Data preparation
# -------------------------------
cyclistic_all <- cyclistic_all %>%
  mutate(
    started_at   = ymd_hms(started_at),
    ended_at     = ymd_hms(ended_at),
    ride_length  = as.numeric(difftime(ended_at, started_at, units = "mins")),
    day_of_week  = wday(started_at, label = TRUE, abbr = TRUE),
    hour         = hour(started_at)
  ) %>%
  filter(ride_length > 0)   # remove negative or zero rides

# -------------------------------
# Define custom colors
# -------------------------------
user_colors <- c(
  "member" = "#1f78b4",
  "casual" = "#33a02c"
)

# =========================================================
# 1. Rides by Day of Week
# =========================================================
rides_by_day <- cyclistic_all %>%
  group_by(member_casual, day_of_week) %>%
  summarise(rides = n(), .groups = "drop")

p1 <- ggplot(rides_by_day,
             aes(x = day_of_week,
                 y = rides,
                 fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = user_colors) +
  labs(
    title = "Rides by Day of Week",
    subtitle = "Comparison between Annual Members and Casual Riders",
    x = "Day of Week",
    y = "Number of Rides",
    fill = "User Type"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/rides_by_day.png",
       p1, width = 8, height = 5)

# =========================================================
# 2. Ride Length Distribution (Boxplot with Colored Points)
# =========================================================
p2 <- ggplot(cyclistic_all,
             aes(x = member_casual,
                 y = ride_length,
                 fill = member_casual,
                 color = member_casual)) +
  geom_boxplot(outlier.shape = NA, linewidth = 0.8, alpha = 0.4) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1.5) +
  scale_fill_manual(values = user_colors) +
  scale_color_manual(values = user_colors) +
  labs(
    title = "Ride Length Distribution by User Type",
    subtitle = "Casual riders generally take longer rides",
    x = "User Type",
    y = "Ride Length (minutes)"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/ride_length_boxplot.png",
       p2, width = 8, height = 5)

# =========================================================
# 3. Ride Counts by Hour of Day
# =========================================================
rides_by_hour <- cyclistic_all %>%
  group_by(member_casual, hour) %>%
  summarise(rides = n(), .groups = "drop")

p3 <- ggplot(rides_by_hour,
             aes(x = hour,
                 y = rides,
                 color = member_casual)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = user_colors) +
  labs(
    title = "Ride Counts by Hour of Day",
    subtitle = "Members peak during commute hours; casuals ride midday",
    x = "Hour of Day",
    y = "Number of Rides",
    color = "User Type"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/rides_by_hour.png",
       p3, width = 8, height = 5)

# =========================================================
# 4. Total Rides per Month
# =========================================================
cyclistic_all <- cyclistic_all %>%
  mutate(month = floor_date(started_at, "month"))

rides_by_month <- cyclistic_all %>%
  group_by(member_casual, month) %>%
  summarise(rides = n(), .groups = "drop")

p4 <- ggplot(rides_by_month,
             aes(x = month,
                 y = rides,
                 color = member_casual)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = user_colors) +
  labs(
    title = "Total Rides per Month",
    subtitle = "Clear seasonal trends across rider types",
    x = "Month",
    y = "Number of Rides",
    color = "User Type"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/rides_by_month.png",
       p4, width = 8, height = 5)

# =========================================================
# 5. Short vs Long Rides (Pie Chart)
# =========================================================
cyclistic_all <- cyclistic_all %>%
  mutate(ride_category = ifelse(ride_length <= 30, "Short (≤ 30 min)", "Long (> 30 min)"))

rides_by_category <- cyclistic_all %>%
  group_by(member_casual, ride_category) %>%
  summarise(count = n(), .groups = "drop")

p5 <- ggplot(rides_by_category,
             aes(x = "",
                 y = count,
                 fill = ride_category)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  facet_wrap(~ member_casual) +
  scale_fill_manual(values = c("Short (≤ 30 min)" = "#1f78b4", "Long (> 30 min)" = "#33a02c")) +
  labs(
    title = "Proportion of Short vs Long Rides",
    subtitle = "Members favor short trips; casual riders take longer rides",
    fill = "Ride Length Category"
  ) +
  theme_void(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/ride_length_pie.png",
       p5, width = 8, height = 5)

# =========================================================
# 6. Average Ride Length by Day of Week (Line Chart)
# =========================================================
avg_ride_by_day <- cyclistic_all %>%
  group_by(member_casual, day_of_week) %>%
  summarise(avg_ride_length = mean(ride_length, na.rm = TRUE), .groups = "drop")

p6 <- ggplot(avg_ride_by_day,
             aes(x = day_of_week,
                 y = avg_ride_length,
                 group = member_casual,
                 color = member_casual)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_color_manual(values = user_colors) +
  labs(
    title = "Average Ride Length by Day of Week",
    subtitle = "Casual riders have longer rides across all days",
    x = "Day of Week",
    y = "Average Ride Length (minutes)",
    color = "User Type"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/avg_ride_by_day.png",
       p6, width = 8, height = 5)

# =========================================================
# 7. Average Ride Length by User Type (Bar Chart, thinner bars)
# =========================================================
avg_ride_by_type <- cyclistic_all %>%
  group_by(member_casual) %>%
  summarise(avg_ride_length = mean(ride_length, na.rm = TRUE), .groups = "drop")

p7 <- ggplot(avg_ride_by_type,
             aes(x = member_casual,
                 y = avg_ride_length,
                 fill = member_casual)) +
  geom_col(width = 0.4) +
  scale_fill_manual(values = user_colors) +
  labs(
    title = "Average Ride Length by User Type",
    subtitle = "Casual riders have higher average ride duration",
    x = "User Type",
    y = "Average Ride Length (minutes)",
    fill = "User Type"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/avg_ride_by_type.png",
       p7, width = 8, height = 5)

# =========================================================
# 8. Ride Length Distribution (Boxplot with Vertical Points)
# =========================================================
p8 <- ggplot(cyclistic_all,
             aes(x = member_casual,
                 y = ride_length,
                 fill = member_casual,
                 color = member_casual)) +
  geom_boxplot(outlier.shape = NA, linewidth = 0.8, alpha = 0.4) +
  geom_jitter(width = 0, alpha = 0.3, size = 1.5) +  # vertical line of points
  scale_fill_manual(values = user_colors) +
  scale_color_manual(values = user_colors) +
  labs(
    title = "Ride Length Distribution by User Type",
    subtitle = "Casual riders generally take longer rides",
    x = "User Type",
    y = "Ride Length (minutes)"
  ) +
  theme_minimal(base_size = 14)

ggsave("~/Desktop/Cyclistic-Analysis/visuals/ride_length_boxplot_vertical.png",
       p8, width = 8, height = 5)

# =========================================================
# End of Script
# =========================================================
