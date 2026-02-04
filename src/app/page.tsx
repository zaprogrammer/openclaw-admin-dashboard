'use client';

import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Tabs, { TabId } from '@/components/Tabs';
import SoulTab from '@/components/SoulTab';
import UserTab from '@/components/UserTab';
import { Agent } from '@/types/agent';

function HomeContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const tabParam = searchParams.get('tab') as TabId;
  const [activeTab, setActiveTab] = useState<TabId>('tools');
  const [agent, setAgent] = useState<Agent>({
    name: 'saul-goodman',
    description: '',
    systemPrompt: '',
    skills: { enabled: [] },
    tools: { enabled: [], disabled: [] },
  });

  useEffect(() => {
    if (tabParam && ['soul', 'user', 'agents', 'memory', 'tools', 'skills'].includes(tabParam)) {
      setActiveTab(tabParam);
    }
  }, [tabParam]);

  const handleTabChange = (tabId: TabId) => {
    setActiveTab(tabId);
    router.push(`?tab=${tabId}`, { scroll: false });
  };

  const handleAgentSave = (updatedAgent: Agent) => {
    setAgent(updatedAgent);
    console.log('Agent saved:', updatedAgent);
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'soul':
        return <SoulTab agent={agent} onSave={handleAgentSave} />;
      case 'user':
        return <UserTab agent={agent} onSave={handleAgentSave} />;
      case 'agents':
        return (
          <div className="p-6 animate-in fade-in duration-150">
            <h2 className="text-xl font-semibold mb-4">Agent Permissions</h2>
            <p className="text-[#6b7280]">Configure which other agents this agent can communicate with.</p>
          </div>
        );
      case 'memory':
        return (
          <div className="p-6 animate-in fade-in duration-150">
            <h2 className="text-xl font-semibold mb-4">Memory Scope</h2>
            <p className="text-[#6b7280]">Configure which memory files the agent can access.</p>
          </div>
        );
      case 'tools':
        return (
          <div className="p-6 animate-in fade-in duration-150">
            <h2 className="text-xl font-semibold mb-4">Tool Permissions</h2>
            <p className="text-[#6b7280]">Configure tool permissions for this agent.</p>
          </div>
        );
      case 'skills':
        return (
          <div className="p-6 animate-in fade-in duration-150">
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
        <Tabs activeTab={activeTab} onTabChange={handleTabChange} />
      </div>
      <div className="bg-[#1a1a1a] border-x border-b border-[#2a2a2a] rounded-b-lg min-h-[calc(100vh-12rem)]">
        {renderTabContent()}
      </div>
    </div>
  );
}

export default function Home() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HomeContent />
    </Suspense>
  );
}
