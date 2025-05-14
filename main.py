import gymnasium as gym
import numpy as np

# Set up LunarLander environment
env = gym.make("LunarLander-v3", render_mode=None)

NUM_EPISODES = 100
total_rewards = []

for episode in range(NUM_EPISODES):
    obs, _ = env.reset()
    done = False
    total_reward = 0

    while not done:
        action = env.action_space.sample()  # Random policy
        obs, reward, terminated, truncated, _ = env.step(action)
        done = terminated or truncated
        total_reward += reward

    total_rewards.append(total_reward)

# Save summary
print(f"Ran {NUM_EPISODES} episodes")
print(f"Average reward: {np.mean(total_rewards):.2f}")
