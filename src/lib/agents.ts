import { Agent } from '@/types/agent';

const AGENTS_DIR = '/Users/.openclaw/agents';

export async function loadAgents(): Promise<Agent[]> {
  try {
    const response = await fetch('/api/agents');
    if (!response.ok) {
      throw new Error('Failed to load agents');
    }
    return await response.json();
  } catch (error) {
    console.error('Error loading agents:', error);
    return [];
  }
}

export function getSkillCount(agent: Agent): number {
  return agent.skills.enabled.length;
}
