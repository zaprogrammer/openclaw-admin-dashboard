'use client';

import { useState, useEffect, useCallback } from 'react';
import { Agent } from '@/types/agent';

interface SoulTabProps {
  agent: Agent;
  onSave: (agent: Agent) => void;
}

export default function SoulTab({ agent, onSave }: SoulTabProps) {
  const [name, setName] = useState(agent.name || '');
  const [description, setDescription] = useState(agent.description || '');
  const [systemPrompt, setSystemPrompt] = useState(agent.systemPrompt || '');
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  const DESCRIPTION_LIMIT = 1000;
  const SYSTEM_PROMPT_LIMIT = 2000;

  useEffect(() => {
    setHasUnsavedChanges(
      name !== agent.name ||
      description !== (agent.description || '') ||
      systemPrompt !== (agent.systemPrompt || '')
    );
  }, [name, description, systemPrompt, agent]);

  const handleSave = useCallback(() => {
    const updatedAgent: Agent = {
      ...agent,
      name,
      description,
      systemPrompt,
    };
    onSave(updatedAgent);
    setHasUnsavedChanges(false);
  }, [agent, name, description, systemPrompt, onSave]);

  useEffect(() => {
    const timer = setTimeout(() => {
      if (hasUnsavedChanges) {
        handleSave();
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [hasUnsavedChanges, handleSave]);

  return (
    <div className="p-6 animate-in fade-in duration-150">
      <div className="max-w-3xl">
        <h2 className="text-xl font-semibold mb-4">Soul Configuration</h2>
        <p className="text-[#6b7280] mb-6">
          Configure agent personality, identity, and behavioral instructions.
        </p>

        <div className="space-y-6">
          {/* Name Field */}
          <div>
            <label htmlFor="agent-name" className="block text-sm font-medium mb-2">
              Agent Name
            </label>
            <input
              id="agent-name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-4 py-2 bg-[#0a0a0a] border border-[#2a2a2a] rounded-lg text-white placeholder-[#6b7280] focus:outline-none focus:border-[#3b82f6] focus:ring-1 focus:ring-[#3b82f6]"
              placeholder="e.g., saul-goodman"
            />
          </div>

          {/* Description Field */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <label htmlFor="agent-description" className="block text-sm font-medium">
                Personality & Behavioral Instructions
              </label>
              <span className="text-sm text-[#6b7280]">
                {description.length}/{DESCRIPTION_LIMIT} characters
              </span>
            </div>
            <textarea
              id="agent-description"
              value={description}
              onChange={(e) => setDescription(e.target.value.slice(0, DESCRIPTION_LIMIT))}
              rows={6}
              className="w-full px-4 py-2 bg-[#0a0a0a] border border-[#2a2a2a] rounded-lg text-white placeholder-[#6b7280] focus:outline-none focus:border-[#3b82f6] focus:ring-1 focus:ring-[#3b82f6] resize-y"
              placeholder="Describe the agent's personality, behavior patterns, and tone of communication..."
            />
          </div>

          {/* System Prompt Field */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <label htmlFor="agent-system-prompt" className="block text-sm font-medium">
                System Instructions
              </label>
              <span className="text-sm text-[#6b7280]">
                {systemPrompt.length}/{SYSTEM_PROMPT_LIMIT} characters
              </span>
            </div>
            <textarea
              id="agent-system-prompt"
              value={systemPrompt}
              onChange={(e) => setSystemPrompt(e.target.value.slice(0, SYSTEM_PROMPT_LIMIT))}
              rows={8}
              className="w-full px-4 py-2 bg-[#0a0a0a] border border-[#2a2a2a] rounded-lg text-white placeholder-[#6b7280] focus:outline-none focus:border-[#3b82f6] focus:ring-1 focus:ring-[#3b82f6] resize-y font-mono text-sm"
              placeholder="System-level instructions for the AI model..."
            />
          </div>

          {/* Save Button */}
          <div className="flex items-center gap-4">
            <button
              onClick={handleSave}
              disabled={!hasUnsavedChanges}
              className={`
                px-6 py-2 rounded-lg font-medium transition-colors
                ${hasUnsavedChanges
                  ? 'bg-[#3b82f6] hover:bg-[#2563eb] text-white'
                  : 'bg-[#2a2a2a] text-[#6b7280] cursor-not-allowed'
                }
              `}
            >
              {hasUnsavedChanges ? 'Save Changes' : 'Saved'}
            </button>
            {hasUnsavedChanges && (
              <span className="text-sm text-[#6b7280]">Auto-save enabled (300ms)</span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
