'use client';

import { useState, useEffect, useCallback } from 'react';
import { Agent } from '@/types/agent';

interface UserTabProps {
  agent: Agent;
  onSave: (agent: Agent) => void;
}

interface UserProfile {
  id: string;
  name: string;
  path: string;
}

export default function UserTab({ agent, onSave }: UserTabProps) {
  const [enabled, setEnabled] = useState(agent.user?.enabled ?? false);
  const [scope, setScope] = useState<'all' | 'specific' | 'none'>(agent.user?.scope ?? 'none');
  const [selectedFiles, setSelectedFiles] = useState<string[]>(agent.user?.files ?? []);
  const [availableProfiles, setAvailableProfiles] = useState<UserProfile[]>([]);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  useEffect(() => {
    const mockProfiles: UserProfile[] = [
      { id: '1', name: 'default', path: '~/.openclaw/users/default/' },
      { id: '2', name: 'developer', path: '~/.openclaw/users/developer/' },
      { id: '3', name: 'analyst', path: '~/.openclaw/users/analyst/' },
    ];
    setAvailableProfiles(mockProfiles);
  }, []);

  useEffect(() => {
    setHasUnsavedChanges(
      enabled !== (agent.user?.enabled ?? false) ||
      scope !== (agent.user?.scope ?? 'none') ||
      JSON.stringify(selectedFiles) !== JSON.stringify(agent.user?.files ?? [])
    );
  }, [enabled, scope, selectedFiles, agent]);

  const handleSave = useCallback(() => {
    const updatedAgent: Agent = {
      ...agent,
      user: {
        enabled,
        scope,
        files: scope === 'specific' ? selectedFiles : [],
      },
    };
    onSave(updatedAgent);
    setHasUnsavedChanges(false);
  }, [agent, enabled, scope, selectedFiles, onSave]);

  useEffect(() => {
    const timer = setTimeout(() => {
      if (hasUnsavedChanges) {
        handleSave();
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [hasUnsavedChanges, handleSave]);

  const toggleFile = (fileId: string) => {
    setSelectedFiles(prev =>
      prev.includes(fileId)
        ? prev.filter(id => id !== fileId)
        : [...prev, fileId]
    );
  };

  return (
    <div className="p-6 animate-in fade-in duration-150">
      <div className="max-w-3xl">
        <h2 className="text-xl font-semibold mb-4">User Context Configuration</h2>
        <p className="text-[#6b7280] mb-6">
          Configure which user context/profile the agent can access.
        </p>

        <div className="space-y-6">
          {/* Enable User Context */}
          <div className="flex items-center justify-between p-4 bg-[#0a0a0a] border border-[#2a2a2a] rounded-lg">
            <div>
              <h3 className="font-medium mb-1">Enable User Context Access</h3>
              <p className="text-sm text-[#6b7280]">
                Allow the agent to access user profile information
              </p>
            </div>
            <button
              onClick={() => setEnabled(!enabled)}
              className={`
                relative w-12 h-6 rounded-full transition-colors
                ${enabled ? 'bg-[#3b82f6]' : 'bg-[#2a2a2a]'}
              `}
            >
              <span
                className={`
                  absolute top-1 w-4 h-4 bg-white rounded-full transition-transform
                  ${enabled ? 'left-7' : 'left-1'}
                `}
              />
            </button>
          </div>

          {/* Scope Selector */}
          {enabled && (
            <div className="p-4 bg-[#0a0a0a] border border-[#2a2a2a] rounded-lg">
              <h3 className="font-medium mb-4">Access Scope</h3>
              <div className="space-y-3">
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="radio"
                    name="scope"
                    value="all"
                    checked={scope === 'all'}
                    onChange={(e) => setScope(e.target.value as 'all' | 'specific' | 'none')}
                    className="w-4 h-4 text-[#3b82f6] bg-[#0a0a0a] border-[#2a2a2a] focus:ring-[#3b82f6]"
                  />
                  <div>
                    <div className="font-medium">All Files</div>
                    <div className="text-sm text-[#6b7280]">Access all user profile files</div>
                  </div>
                </label>

                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="radio"
                    name="scope"
                    value="specific"
                    checked={scope === 'specific'}
                    onChange={(e) => setScope(e.target.value as 'all' | 'specific' | 'none')}
                    className="w-4 h-4 text-[#3b82f6] bg-[#0a0a0a] border-[#2a2a2a] focus:ring-[#3b82f6]"
                  />
                  <div>
                    <div className="font-medium">Specific Files</div>
                    <div className="text-sm text-[#6b7280]">Select specific files to access</div>
                  </div>
                </label>

                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="radio"
                    name="scope"
                    value="none"
                    checked={scope === 'none'}
                    onChange={(e) => setScope(e.target.value as 'all' | 'specific' | 'none')}
                    className="w-4 h-4 text-[#3b82f6] bg-[#0a0a0a] border-[#2a2a2a] focus:ring-[#3b82f6]"
                  />
                  <div>
                    <div className="font-medium">No Access</div>
                    <div className="text-sm text-[#6b7280]">No access to user context files</div>
                  </div>
                </label>
              </div>
            </div>
          )}

          {/* Specific Files List */}
          {enabled && scope === 'specific' && (
            <div className="p-4 bg-[#0a0a0a] border border-[#2a2a2a] rounded-lg">
              <h3 className="font-medium mb-4">Available User Profiles</h3>
              <div className="space-y-2">
                {availableProfiles.map((profile) => (
                  <label
                    key={profile.id}
                    className="flex items-center justify-between p-3 bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg cursor-pointer hover:border-[#3b82f6] transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        checked={selectedFiles.includes(profile.id)}
                        onChange={() => toggleFile(profile.id)}
                        className="w-4 h-4 text-[#3b82f6] bg-[#0a0a0a] border-[#2a2a2a] rounded focus:ring-[#3b82f6]"
                      />
                      <div>
                        <div className="font-medium">{profile.name}</div>
                        <div className="text-sm text-[#6b7280]">{profile.path}</div>
                      </div>
                    </div>
                  </label>
                ))}
              </div>
              {availableProfiles.length === 0 && (
                <p className="text-[#6b7280]">No user profiles found in ~/.openclaw/users/</p>
              )}
            </div>
          )}

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