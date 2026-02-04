'use client';

import { useState } from 'react';
import Tabs, { TabId } from '@/components/Tabs';

export default function Home() {
  const [activeTab, setActiveTab] = useState<TabId>('tools');

  const renderTabContent = () => {
    switch (activeTab) {
      case 'soul':
        return (
          <div className="p-6">
            <h2 className="text-xl font-semibold mb-4">Soul Configuration</h2>
            <p className="text-[#6b7280]">Configure agent personality and identity.</p>
          </div>
        );
      case 'user':
        return (
          <div className="p-6">
            <h2 className="text-xl font-semibold mb-4">User Context</h2>
            <p className="text-[#6b7280]">Configure which user context/profile the agent can access.</p>
          </div>
        );
      case 'agents':
        return (
          <div className="p-6">
            <h2 className="text-xl font-semibold mb-4">Agent Permissions</h2>
            <p className="text-[#6b7280]">Configure which other agents this agent can communicate with.</p>
          </div>
        );
      case 'memory':
        return (
          <div className="p-6">
            <h2 className="text-xl font-semibold mb-4">Memory Scope</h2>
            <p className="text-[#6b7280]">Configure which memory files the agent can access.</p>
          </div>
        );
      case 'tools':
        return (
          <div className="p-6">
            <h2 className="text-xl font-semibold mb-4">Tool Permissions</h2>
            <p className="text-[#6b7280]">Configure tool permissions for this agent.</p>
          </div>
        );
      case 'skills':
        return (
          <div className="p-6">
            <h2 className="text-xl font-semibold mb-4">Skills Management</h2>
            <p className="text-[#6b7280]">Manage skills for this agent.</p>
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white">
      <div className="p-8 pb-0">
        <h1 className="text-3xl font-bold mb-2">OpenClaw Admin Panel</h1>
        <p className="text-[#6b7280] mb-6">
          Granular permission management for AI agents
        </p>
      </div>
      <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-t-lg mt-0">
        <Tabs activeTab={activeTab} onTabChange={setActiveTab} />
      </div>
      <div className="bg-[#1a1a1a] border-x border-b border-[#2a2a2a] rounded-b-lg min-h-[calc(100vh-12rem)]">
        {renderTabContent()}
      </div>
    </div>
  );
}
