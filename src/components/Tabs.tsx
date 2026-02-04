'use client';

import { useState } from 'react';

export type TabId = 'soul' | 'user' | 'agents' | 'memory' | 'tools' | 'skills';

interface Tab {
  id: TabId;
  icon: string;
  label: string;
}

const TABS: Tab[] = [
  { id: 'soul', icon: '🧑', label: 'Soul' },
  { id: 'user', icon: '👤', label: 'User' },
  { id: 'agents', icon: '🤝', label: 'Agents' },
  { id: 'memory', icon: '🧠', label: 'Memory' },
  { id: 'tools', icon: '🛠️', label: 'Tools' },
  { id: 'skills', icon: '📦', label: 'Skills' },
];

interface TabsProps {
  activeTab: TabId;
  onTabChange: (tabId: TabId) => void;
}

export default function Tabs({ activeTab, onTabChange }: TabsProps) {
  return (
    <div className="h-12 bg-[#1a1a1a] border-b border-[#2a2a2a] flex items-center px-4">
      <div className="flex gap-1">
        {TABS.map((tab) => (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            className={`
              px-4 py-2 rounded-t flex items-center gap-2 text-sm font-medium transition-colors
              ${activeTab === tab.id
                ? 'text-[#3b82f6] border-b-2 border-[#3b82f6] -mb-px'
                : 'text-[#6b7280] hover:text-[#9ca3af]'
              }
            `}
          >
            <span className="text-lg">{tab.icon}</span>
            <span>{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
